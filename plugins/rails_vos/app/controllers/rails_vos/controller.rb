#
# Copyright (C) 2008-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

#require 'active_rest/controller/attribute'
#require 'active_rest/controller/role_def'
#require 'active_rest/controller/view'
#require 'active_rest/controller/exceptions'

module RailsVos

module Controller
  extend ActiveSupport::Concern

  include ActiveSupport::Callbacks

  attr_accessor :cc

  included do
    class_attribute :vos_model
    self.vos_model = nil

    class_attribute :vos_member_actions
    self.vos_member_actions = { show: {}, index: {} }

    class_attribute :vos_collection_actions
    self.vos_collection_actions = { }

    class_attribute :vos_views
    self.vos_views = {}

    class_attribute :vos_options
    self.vos_options = {}

    class_attribute :vos_authorization_required
    self.vos_authorization_required = true

    class_attribute :vos_member_role_defs
    self.vos_member_role_defs = {}

    class_attribute :vos_collection_role_defs
    self.vos_collection_role_defs = {}

    class_attribute :vos_scopes
    self.vos_scopes = {}

    class_attribute :vos_read_only
    self.vos_read_only = false

    class_attribute :vos_transaction_handler
    self.vos_transaction_handler = :vos_default_transaction_handler

    class_attribute :vos_map
    self.vos_map = nil

    class_attribute :vos_config_attrs
    self.vos_config_attrs = {}

    class_attribute :vos_prefix
    self.vos_prefix = name ? name.split('::').last.gsub(/Controller$/, '') : nil

    # Authorization
    class_attribute :vos_member_roles_chain
    self.vos_member_roles_chain = []

    class_attribute :vos_collection_roles_chain
    self.vos_collection_roles_chain = []

    class_attribute :vos_all_members_roles_chain
    self.vos_all_members_roles_chain = []

    class << self
      prepend PrependedClassMethods
    end
  end

  def initialize(**args)
    args.each { |k,v| send("#{k}=", v) }
  end

  ######################################## Methods meant to be called from adapter ########################
  #
  # Finders and renderers are reparate because WS adapter needs to interact with the resources themselves
  #

  def vos_render_one(resource, **args)
    vos_hash(resource, **args)
  end

  def vos_render_many(rel, **args)
    reps = rel.map { |resource| vos_hash(resource, **args) }.compact

    vos_merge_hashes(reps, **args)
  end

  def vos_find_one(id)
    resource = vos_model.find(id)
    vos_authorize_member_action(resource: resource, action: :show)

    resource
  end

  def vos_find_many(ids)
    resources = vos_model.find(ids)

    resources.each do |resource|
      vos_authorize_member_action(resource: resource, action: :show)
    end

    resources
  end

  def vos_query(limit: nil, offset: nil, order: nil, filter: nil, index_cache: true)
    vos_authorize_collection_action(action: :index)

    rel = vos_model.all
    rel = vos_filter_by_authorization(rel, cache: index_cache)
    rel = rel.limit(limit) if limit
    rel = rel.offset(offset) if offset
    rel = vos_apply_order(rel, order) if order
    rel = vos_apply_filter(rel, filter) if filter

    rel
  end

  ################ Schema

  def vos_schema
    defs = {}

    vos_attrs.select { |k,v| v.readable || v.writable }.each do |attrname,attr|
      defs[attrname] = attr.definition(ctr_get: method(:vos_ctr_get))
    end

   {
    type: vos_model.to_s,
    attrs: defs,
    member_actions: vos_member_actions,
    collection_actions: vos_collection_actions,
    member_roles: Hash[vos_member_role_defs.map { |k, role| [ k, { } ] }],
    collection_roles: Hash[vos_member_role_defs.map { |k, role| [ k, { } ] }],
   }
  end

  ################ Output

  def vos_hash(obj,
      view: nil,
      authorization: vos_auth_required?,
      **args)

    view = vos_find_view(view)
    roles = []

    if authorization
      roles = vos_member_roles(obj)

      if roles.empty?
        raise ResourceNotReadable.new(obj)
      end
    end

    vos_hash_wc(obj, view: view, roles: roles, authorization: authorization, **args)
  end

  def vos_hash_wc(obj,
      view:,
      roles: [],
      jit_debug: false,
      jit_enabled: true,
      authorization:,
      **args)

    raise ResourceNotReadable.new(self) if authorization && !vos_member_action_allowed?(obj, :show)

    @jit_cache ||= {}
    @jit_defs ||= {}

    # Build a string identifying the representation tuple
    roles_string = roles.sort.join(',')
    jit_proc_name = "jitview:#{format}|#{view.path}|#{roles_string}|#{authorization ? 'auth' : ''}".to_sym

    jit_proc = @jit_cache[jit_proc_name]
    if !jit_proc
      perms = vos_auth_required? ? vos_build_perms_from_roles(roles, vos_member_role_defs) : nil

      jit_def = send("vos_hash_#{format}_builder", roles: roles, view: view, perms: perms,
                  authorization: authorization, **args)

      if jit_debug
        puts "---------- #{self} JIT PROC '#{jit_proc_name}' ------------------------------------------"
        puts jit_def
        puts "---------------------------------------------------------------------------------------"
      end

      jit_proc = instance_eval(jit_def, jit_proc_name.to_s)

      @jit_defs[jit_proc_name] = jit_def if jit_enabled
      @jit_cache[jit_proc_name] = jit_proc if jit_enabled
    end

    begin
      jit_proc.call(obj, view)
    rescue StandardError => e
      puts "Exception in JIT compiled view:\n-----------------------\n#{@jit_defs[jit_proc_name]}\n---------------------------\n"
      raise
    end

  rescue ResourceNotReadable
    raise
  end

  ################# Writing

  def vos_apply_creation_attributes(obj, resource_object:, authorization: vos_auth_required?, **args)
    vos_apply_attributes(obj, resource_object: resource_object, creating: true, authorization: authorization, **args)
  end

  def vos_apply_update_attributes(obj, resource_object:, authorization: vos_auth_required?, **args)
    vos_apply_attributes(obj, resource_object: resource_object, creating: false, authorization: authorization, **args)
  end

  def vos_apply_attributes(obj, resource_object:, creating:, authorization:, **args)
    roles = nil

    if authorization
      if creating
        roles = vos_collection_roles
        perms = vos_build_perms_from_roles(roles, vos_collection_role_defs)
      else
        roles = vos_member_roles(obj)
        perms = vos_build_perms_from_roles(roles, vos_member_role_defs)
      end

      if roles.empty?
        if creating
          raise ResourceNotCreatable.new(obj)
        else
          raise ResourceNotWritable.new(obj)
        end
      end
    end

    send("vos_do_apply_model_attributes_#{format}", obj, resource_object: resource_object, creating: creating, perms: perms, authorization: authorization)
  end

 ################### WS interface reserved methods

  def ws_create(resource_object:, request_id: nil)
    cb_args = { resource_object: resource_object, request_id: request_id }

    vos_authorize_collection_action(action: :create)
    resource = nil
    begin
      send(vos_transaction_handler, request_id: request_id) do
        resource = vos_model.new

        before_create(resource: resource, **cb_args)

        vos_apply_creation_attributes(resource, resource_object: resource_object)

        before_creation_save(resource: resource, **cb_args)
        before_save(resource: resource, **cb_args)

        resource.save!
        after_create(resource: resource, **cb_args)
      end
    end

    after_create_commit(resource: resource, **cb_args)

    resource
  end

  def ws_update(resource, resource_object:, request_id: nil)
    vos_authorize_member_action(resource: resource, action: :update)

    cb_args = { resource: resource, resource_object: resource_object, request_id: request_id }

    begin
      send(vos_transaction_handler, request_id: request_id) do
        before_update(**cb_args)

        vos_apply_update_attributes(resource, resource_object: resource_object)

        before_save(**cb_args)

        resource.save!
        after_update(**cb_args)
      end
    end

    after_update_commit(**cb_args)

    resource
  end

  def ws_destroy(resource, request_id: nil)
    vos_authorize_member_action(resource: resource, action: :destroy)

    cb_args = { resource: resource, request_id: request_id }

    send(vos_transaction_handler, request_id: request_id) do
      before_destroy(**cb_args)
      resource.destroy
      after_destroy(**cb_args)
    end

    after_destroy_commit(**cb_args)

    resource
  end

  ################# Generic stuff/helpers

  def vos_apply_filter(rel, filter)
    filter.each do |k,v|
      begin
        (attr, path) = rel.nested_attribute(k)
        rel = rel.joins(path[0..-1].reverse.inject { |a,x| { x => a } }) if path.any?
        rel = rel.where(attr.eq(v))
      rescue ActiveRest::Model::UnknownField
      end
    end

    rel
  end

  protected

  def vos_merge_hashes(reps, **args)
    vos_merge_hashes_jsonapi(reps, **args)
  end

  def vos_apply_order(rel, order)
    rel = rel.order(order) if order
    rel
  end

  def vos_find_view(view)
    if view.nil?
      vos_views[:_default_] || vos_create_default_view
    elsif view.is_a?(Symbol) || view.is_a?(String)
      if !vos_views[view.to_sym]
        raise ViewNotFound.new(title: "View #{view} not found", title_sym: 'view_not_found', data: { view_name: view })
      end

      vos_views[view.to_sym]
    else
      view
    end
  end

  def vos_create_default_view
    embedded_attrs = vos_attrs.select { |k,v|
      v.is_a?(Attribute::EmbeddedModel) ||
      v.is_a?(Attribute::UniformModelsCollection) ||
      v.is_a?(Attribute::PolymorphicModelsCollection)
    }

    self.class.view :_default_ do
      embedded_attrs.each do |k,v|
        attribute(k) { show! }
      end
    end

    vos_views[:_default_]
  end

  # Authorization =======================

  public

  def vos_auth_required?
    vos_authorization_required?
  end

  def vos_non_member_specific_roles
    roles = Set.new([ :anonymous ])

    if aaa_context
      # First global roles
      roles += aaa_context.global_roles

      roles << :authenticated if aaa_context.authenticated?
    end

    # Then  given to the specific model
    vos_all_members_roles_chain.each do |x|
      roles += instance_exec(&x[:cb])
    end

    roles
  end

  def vos_member_roles(obj, filter: true)
    obj = vos_model.find(obj) if obj.is_a?(Numeric)

    roles = vos_non_member_specific_roles

    # Then  given to the specific object
    vos_member_roles_chain.each do |x|
      roles += instance_exec(obj, &x[:cb])
    end

    # Filter out the roles not relevant to this obj
    roles &= vos_member_role_defs.keys if filter

    roles
  end

  def vos_collection_roles(filter: true)
    roles = Set.new([ :anonymous ])

    if aaa_context
      # First global roles
      roles += aaa_context.global_roles

      roles << :authenticated if aaa_context.authenticated?

      # Then  given to the specific model
      vos_collection_roles_chain.each do |x|
        roles += instance_exec(&x[:cb])
      end
    end

    # Filter out the roles not relevant to this obj
    roles &= vos_collection_role_defs.keys if filter

    roles
  end

  def vos_member_allowed_actions(obj)
    vos_member_build_allowed_actions_from_roles(vos_member_roles(obj))
  end

  def vos_member_action_allowed?(obj, actions)
    return true if !vos_auth_required?
    actions = Set.new([ actions ]) unless actions.respond_to?(:to_set)
    vos_member_allowed_actions(obj).superset?(actions.to_set)
  end

  def vos_collection_allowed_actions
    vos_collection_build_allowed_actions_from_roles(vos_collection_roles)
  end

  def vos_collection_action_allowed?(actions)
    return true if !vos_auth_required?
    actions = Set.new([ actions ]) unless actions.respond_to?(:to_set)
    vos_collection_allowed_actions.superset?(actions.to_set)
  end


  def vos_authorize_member_action(resource:, action:)
    return true if !vos_auth_required?

    unless vos_member_action_allowed?(resource, action)
      raise AuthorizationError.new(
            title: "You do not have the required role to operate action #{action}.",
            title_sym: "you_do_not_have_required_role_for_action",
            data: { action: action })
    end

    true
  end

  def vos_authorize_collection_action(action:)
    return true if !vos_auth_required?

    unless vos_collection_action_allowed?(action)
      raise AuthorizationError.new(
            title: "You do not have the required role to operate action #{action}",
            title_sym: 'you_do_not_have_the require_role_for_action',
            data: { action: action })
    end

    true
  end

  def vos_authorize_attribute(resource:, attribute:)
    vos_authorize_member_action(resource: resource, action: :show)

    if !attr_readable?(attribute)
      raise AuthorizationError.new(
            title: "You do not have the required role to read attribute #{attribute}.",
            title_sym: "you_do_not_have_required_role_to_read_attribute",
            data: { attribute: attribute })
    end

    true
  end

  def attr_readable?(attr, perms: nil, roles: nil)
    attr = vos_attrs[attr] if attr.is_a?(Symbol)

    return false if !attr.readable

    perms ||= vos_build_perms_from_roles(roles, vos_member_role_defs) if roles
    perms ? perms.readable?(attr.name) : true
  end

  def attr_writable?(attr, perms: nil, roles: nil)
    attr = vos_attrs[attr] if attr.is_a?(Symbol)

    return false if !attr.writable

    perms ||= vos_build_perms_from_roles(roles, vos_member_role_defs) if roles
    perms ? perms.writable?(attr.name) : true
  end

  protected

  def vos_build_perms_from_roles(roles, role_defs)

    # Filter out unexistant roles
    roles = roles.select { |x| role_defs[x.to_sym] }

    sorted_roles = roles.sort
    roles_name = sorted_roles.join(',')
    role_defs = sorted_roles.map { |x| role_defs[x.to_sym] }

    perms = role_defs.reduce(RoleDef.new(name: roles_name, interface: nil && self), &:merge!)

    perms
  end

  def vos_member_build_allowed_actions_from_roles(roles)
    perms = vos_build_perms_from_roles(roles, vos_member_role_defs)

    vos_member_build_allowed_actions_from_perms(perms)
  end

  def vos_member_build_allowed_actions_from_perms(perms)
    perms.allow_all_actions ? Set.new(vos_member_actions.keys) : (perms.allowed_actions & vos_member_actions.keys)
  end

  def vos_collection_build_allowed_actions_from_roles(roles)
    perms = vos_build_perms_from_roles(roles, vos_collection_role_defs)

    vos_collection_build_allowed_actions_from_perms(perms)
  end

  def vos_collection_build_allowed_actions_from_perms(perms)
    perms.allow_all_actions ? Set.new(vos_collection_actions.keys) : (perms.allowed_actions & vos_collection_actions.keys)
  end

  public

  def vos_filter_by_authorization(rel, cache: true)
    # Authorization
    if vos_auth_required?
      allowed_actions = vos_member_build_allowed_actions_from_roles(vos_non_member_specific_roles)

      if allowed_actions.include?(:show) && allowed_actions.include?(:index)
        # Well, we know for sure we have :index and :show for all the member, we can cut short and return the whole relation
      else
        if !aaa_context || !aaa_context.authenticated?
          # Don't go any furhter, this relation is not accessible!
          raise AuthorizationError.new(
                title: 'You do not have the required role to access the resources.',
                title_sym: "you_do_not_have_required_role_to_access_resources")
        end

        rel = respond_to?(:authorization_prefilter) ? authorization_prefilter : vos_model.all

        if cache && rel.respond_to?(:idxc_relation)
          vos_model.idxc_check(
            aaa_context: aaa_context,
            rel: rel,
            vos_member_action_allowed: method(:vos_member_action_allowed?),
          )

          rel = rel.idxc_relation(person_id: aaa_context.auth_person.id)
        end
      end
    end

    rel
  end

  #####################################

  def vos_attrs
    self.class.vos_attrs
  end

  def vos_ctr_guess(model)
    model = model.class.name if model.is_a?(ActiveRecord::Base)

    (model.to_s + '::' + vos_prefix + 'Controller')
  end

  def vos_ctr_get(args)
    if args.is_a?(Hash) && args[:for_model]
      name = vos_ctr_guess(args[:for_model])
    elsif args.is_a?(Class)
      name = args.name
    else
      name = args
    end

    @cc ? @cc.get(name) : name.constantize.new(aaa_context: aaa_context)
  end

  #
  # model name to underscore, even when namespaced
  #
  def vos_model_symbol
    vos_model.to_s.underscore.gsub(/\//, '_')
  end

  def to_s
    "<#{self.class.name} model=#{@model.class.name} name=#{@name}>"
  end

#    # Define a scope available to be selected with the :scopes parameter.
#    # The scope itself can be a scope defined in the model or a block operating on the relation.
#    #
#    # If opts is a symbol the scope named as the scope is selected.
#    # If opts is a hash of a single element, the name will be the key and the scope the value.
#    # If opts is a symbol and a block is passed the block will be invoked with the relation as a parameter and should
#    # return a relation with constraints applied. The block is called with the controller's bindings so it can
#    # access params and such.
#    #
#    # Examples:
#    #
#    # scope :name
#    # scope :name => :scopename
#    # scope(:name) { |rel| rel.where(...) }
#    #
#    def scope(opts, &block)
#      if opts.is_a?(Hash)
#        self.vos_scopes[opts.keys.first] = opts.values.first
#      elsif block
#        self.vos_scopes[opts] = block
#      else
#        self.vos_scopes[opts] = opts.to_sym
#      end
#    end

  module PrependedClassMethods
    def inherited(child)
      super(child)

      child.vos_views = vos_views.deep_dup
      child.vos_options = vos_options.deep_dup
      #vos_views.each { |k,v| child.vos_views[k] = v.detached_copy }
      child.vos_member_actions = vos_member_actions.dup
      child.vos_collection_actions = vos_collection_actions.dup
      child.vos_member_role_defs = vos_member_role_defs.deep_dup
      child.vos_collection_role_defs = vos_collection_role_defs.deep_dup
      child.vos_scopes = vos_scopes.deep_dup
      child.vos_map = vos_map.deep_dup
      child.vos_config_attrs = vos_config_attrs.deep_dup if vos_config_attrs
      child.vos_prefix = child.name ? child.name.split('::').last.gsub(/Controller$/, '') : nil

      child.vos_collection_roles_chain = vos_collection_roles_chain.deep_dup
      child.vos_member_roles_chain = vos_member_roles_chain.deep_dup
      child.vos_all_members_roles_chain = vos_all_members_roles_chain.deep_dup
    end
  end

  module ClassMethods
    def vos_controller_for(vos_model, options = {})
      self.vos_model = vos_model
      self.vos_options = options
      self.vos_views = {}
      self.vos_scopes = {}
      self.vos_map = nil
      self.vos_config_attrs = {}
    end

    def member_action(name)
      vos_member_actions[name.to_sym] = {}
    end

    def reset_member_actions!
      vos_member_actions.clear
    end

    def collection_action(name)
      vos_collection_actions[name.to_sym] = {}
    end

    def reset_collection_actions!
      vos_collection_actions.clear
    end

    def attribute(name, type: nil, name_in_model: name, &block)
      a = vos_map || vos_config_attrs
      name = name.to_sym

      if name.is_a?(Hash)
        name_in_model, name = name.keys.first, name.values.first
      end

      if type
        begin
          cls = "ActiveRest::Controller::Attribute::#{type.to_s.camelize}".constantize
        rescue NameError
          cls = ActiveRest::Controller::Attribute
        end

        if a[name] && a[name].class == ActiveRest::Controller::Attribute && a[name].class != cls
          raise "Incompatible attribute types #{a[name].class} vs #{type.camelize}"
        end

        newattr = cls.new(name)
        newattr.apply(a[name]) if a[name]
        a[name] = newattr
      else
        a[name] ||= Attribute.new(name, name_in_model: name_in_model)
      end

      a[name].instance_exec(&block) if block
    end

    def remove_attribute(name)
      if vos_map
        vos_map.delete name
      else
        vos_config_attrs[name] = false
      end
    end

    def view(name, &block)
      name = name.to_sym
      vos_views[name] ||= ActiveRest::Controller::View.new(name: name, path: "#{self.name}[#{name}]")
      vos_views[name].instance_exec(&block) if block
      vos_views[name]
    end

    def vos_attrs
      initialize_attrs if !vos_map
      vos_map
    end

    def initialize_attrs
      if !vos_options[:disable_autoconfig]
        initialize_attrs_from_model
      else
        self.vos_map = vos_config_attrs || {}
        self.vos_config_attrs = nil
      end

      vos_map
    end

    def initialize_attrs_from_model
      self.vos_map = {}

      vos_model.columns.each do |column|
        name = column.name.to_sym

        type = map_column_type(column.type)
        type = :object if vos_model.type_for_attribute(column.name).is_a?(ActiveRecord::Type::Serialized)

        vos_map[name] =
          Attribute.new(name,
            type: type,
            default: column.default,
            notnull: !column.null,
            ignored: name == :id,
            writable: ![ :id, :created_at, :updated_at ].include?(name),
          )
      end

#      vos_model.aggregate_reflections.each do |name, reflection|
#        name = name.to_sym
#
#        case reflection
#        when ActiveRecord::Reflection::AggregateReflection
#          vos_map[name] =
#            Attribute::Structure.new(name, type: 'composed_of', model_class: reflection.options[:class_name])
#
#          # Hide attributes composing the structure
#          reflection.options[:mapping].each { |x| mark_attr_to_be_excluded(x[0].to_sym) }
#        end
#      end

      vos_model.reflections.each do |name, reflection|
        name = name.to_sym

        case reflection.macro
        when :belongs_to
          if reflection.options[:polymorphic]
            if reflection.options[:embedded]
              vos_map[name] = Attribute::EmbeddedPolymorphicModel.new(name)

              mark_attr_to_be_excluded(reflection.foreign_key.to_sym)
              mark_attr_to_be_excluded(reflection.foreign_type.to_sym)
            else
              vos_map[name] = Attribute::PolymorphicReference.new(name)
            end
          else
            if reflection.options[:embedded]
              vos_map[name] =
                Attribute::EmbeddedModel.new(name,
                  model_class: reflection.class_name,
                  can_be_eager_loaded: true)

              # Hide embedded foreign key column
              mark_attr_to_be_excluded(reflection.foreign_key.to_sym)
            elsif reflection.options[:embedded_in]
              mark_attr_to_be_excluded(reflection.foreign_key.to_sym)
            else
              vos_map[name] =
                Attribute::Reference.new(name,
                  model_class: reflection.class_name,
                  foreign_key: reflection.foreign_key.to_s,
                  can_be_eager_loaded: true)
            end
          end

        when :has_one
          if reflection.options[:polymorphic]
            if reflection.options[:embedded]
              vos_map[name] = Attribute::EmbeddedPolymorphicModel.new(name)

              mark_attr_to_be_excluded(reflection.foreign_key.to_sym)
              mark_attr_to_be_excluded(reflection.foreign_type.to_sym)
            else
              vos_map[name] = Attribute::PolymorphicReference.new(name)
            end
          else
            if reflection.options[:embedded]
              vos_map[name] =
                Attribute::EmbeddedModel.new(name,
                  model_class: reflection.class_name,
                  can_be_eager_loaded: true)

              # Hide embedded foreign key column
              mark_attr_to_be_excluded(reflection.foreign_key.to_sym)
            else
              vos_map[name] =
                Attribute::Reference.new(name,
                  model_class: reflection.class_name,
                  can_be_eager_loaded: true)
            end
          end

        when :has_many
          if reflection.options[:embedded]
            vos_map[name] =
              Attribute::UniformModelsCollection.new(name,
                model_class: reflection.class_name,
                can_be_eager_loaded: true)
          else
            vos_map[name] =
              Attribute::UniformReferencesCollection.new(name,
                model_class: reflection.class_name,
                foreign_key: (!reflection.is_a?(ActiveRecord::Reflection::ThroughReflection) ? reflection.foreign_key : nil),
                foreign_type: (!reflection.is_a?(ActiveRecord::Reflection::ThroughReflection) ? reflection.type : nil),
                as: reflection.options[:as],
                can_be_eager_loaded: true)
          end

        else
          raise "Usupported reflection of type '#{reflection.macro}'"
        end
      end

      self.vos_config_attrs ||= {}
      vos_config_attrs.each do |attrname, attr|
        if attr === false
          vos_map.delete attrname
        elsif vos_map[attrname]

          if vos_map[attrname].is_a?(Attribute::UniformModelsCollection) && attr.is_a?(Attribute::PolymorphicModelsCollection) ||
             vos_map[attrname].is_a?(Attribute::UniformReferencesCollection) && attr.is_a?(Attribute::PolymorphicReferencesCollection)
            attr.apply(vos_map[attrname])
            vos_map[attrname] = attr
          else
            vos_map[attrname].apply(attr)
          end
        else
          vos_map[attrname] = attr
        end
      end

      vos_map
    end

    def map_column_type(type)
      case type
      when :datetime
        :timestamp
      when :text,
           :macaddr,
           :inet,
           :cidr
        :string
      else
        type
      end
    end

    def mark_attr_to_be_excluded(name)
      if vos_map[name]
        vos_map[name].exclude!
      else
        vos_config_attrs ||= {}
        vos_config_attrs[name] ||= Attribute.new(name, interface: @interface)
        vos_config_attrs[name].exclude!
      end
    end

    # ========= Authorization

    def member_role(name, attrs: {}, **args)
      name = name.to_sym

      vos_member_role_defs[name] = RoleDef.new(name: name, interface: self, attrs: attrs, **args)
    end

    def collection_role(name, attrs: {}, **args)
      name = name.to_sym

      vos_collection_role_defs[name] = RoleDef.new(name: name, interface: self, attrs: attrs, **args)
    end

    def build_member_roles(name, opts: {}, &block)
      vos_member_roles_chain << { name: name, cb: block, opts: opts }
    end

    def build_collection_roles(name, opts: {}, &block)
      vos_collection_roles_chain << { name: name, cb: block, opts: opts }
    end

    def build_all_member_roles(name, opts: {}, &block)
      vos_all_members_roles_chain << { name: name, cb: block, opts: opts }
    end
  end

  protected

  # Empty callbacks
  def before_save(**cb_args) ; end

  def before_create(**cb_args) ; end
  def before_creation_save(**cb_args) ; end
  def after_create(**cb_args) ; end
  def after_create_commit(**cb_args) ; end

  def before_update(**cb_args) ; end
  def after_update(**cb_args) ; end
  def after_update_commit(**cb_args) ; end

  def before_destroy(**cb_args) ; end
  def after_destroy(**cb_args) ; end
  def after_destroy_commit(**cb_args) ; end
end

end
