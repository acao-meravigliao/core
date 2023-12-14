#
# Copyright (C) 2008-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

class RestController < AuthenticatedController

  include RailsActiveRest::Controller
  include Ygg::Hel::ModelHasAcl

  member_action :show
  member_action :index
  member_action :update
  member_action :destroy
  member_action :replicas_force

  member_role(:superuser,
    allow_all_actions: true,
    all_readable: true,
    all_writable: true,
  )

  collection_action :index
  collection_action :create

  collection_role(:superuser,
    allow_all_actions: true,
    all_readable: true,
    all_writable: true,
  )

  self.ar_transaction_handler = :transaction_handler

  set_callback(:ar_retrieve_resource, :after) do
    request.env["exception_notifier.exception_data"] = {
      resource: ar_resource,
    }
  end

  # log action is inherits by all ExtjsControllers and can be used by Ext application to access object's log
  #
  # == Request Parameters
  #
  # [params[:filter]]   Expression in json format to filter results
  # [params[:sort]]     Sort attribute
  # [params[:dir]]      Sort direction (ASC/DESC)
  # [params[:start]]    Pagination offset
  # [params[:limit]]    Pagination limit
  # [params[:<fld>]]  Implement simple filtering by adding == condition between <fld> and parameter value
  #
  def log_entries
    ar_retrieve_resource
    ar_authorize_attribute(resource: ar_resource, attribute: :log_entries)

    # I found no better way to do a modified internal redirection to another controller
    ctrl = Ygg::Core::LogEntry::RestController.new(aaa_context: aaa_context)
    ctrl.request = request
    ctrl.response = response
    ctrl.action_name = 'log_entries'
    ctrl.ar_authorization_required = false

    rel = ar_resource.log_entries

    if params[:sort]
      sorts = params[:sort].split(',')

      sorts.each do |sort|
        if sort =~ /^([-+]?)(.*)$/
          desc = ($1 && $1 == '-')
          attrname = $2

          attr = rel.table[attrname]

          # Call .asc explicitly to overcome a bug in pgsql adapter leading to undefined method to_sql
          attr = desc ? attr.desc : attr.asc

          rel = rel.order(attr)
        end
      end
    end

    ctrl.ar_respond_with_collection(rel)
    self.response_body = ctrl.response_body
  end

#  def acl_entries
#    ar_retrieve_resource
#    ar_authorize_attribute(attribute: :acl_entries)
#
#    # I found no better way to do a modified internal redirection to another controller
#    ctrl = Ygg::Core::LogEntry::RestController.new(aaa_context: aaa_context)
#    ctrl.request = request
#    ctrl.response = response
#    ctrl.action_name = 'acl_entries'
#    ctrl.ar_authorization_required = false
#    ctrl.ar_resources_relation = ar_resource.acl_entries
#    ctrl.index
#    self.response_body = ctrl.response_body
#  end

  # notifications action is inherits by all ExtjsControllers and can be used by Ext application to access object's notifications
  #
  # == Request Parameters
  #
  # [params[:filter]]   Expression in json format to filter results
  # [params[:sort]]     Sort attribute
  # [params[:dir]]      Sort direction (ASC/DESC)
  # [params[:start]]    Pagination offset
  # [params[:limit]]    Pagination limit
  # [params[:<fld>]]  Implement simple filtering by adding == condition between <fld> and parameter value
  #
  def notifications
#    ar_retrieve_resource
#    ar_authorize_attribute(attribute: :notifications)
#
#    rel = (aaa_context.has_global_roles?(:superuser) || aaa_context.has_global_roles?(:voyeour)) ?
#             ar_resource.notifications : ar_resource.my_notifications
#    rel = apply_json_filter_to_relation(ar_resource.notifications)
##    rel = apply_simple_filter_to_relation(rel)
#    rel = apply_sorting_to_relation(rel)
#    rel_pag = apply_pagination_to_relation(rel)
#
#    ctrl = Ygg::Ml::Msg::RestController.new
#    ctrl.request = request
#    ctrl.response = response
#    ctrl.action_name = 'index'
#    ctrl.ar_view = :index
#    ctrl.ar_authorization_required = false
#    ctrl.ar_resources_relation = rel_pag
#    ctrl.index
#    self.response_body = ctrl.response_body
  end

  def request_deletion
    hel_transaction('Deletion requested') do |transaction|
      ar_retrieve_resource
      ar_authorize_member_action

      ar_resource.request_destroy
    end

    render(json: { })
  end

  def replicas_force
    hel_transaction('Forced replica requested') do |transaction|
      ar_retrieve_resource
      ar_authorize_member_action

      ar_resource.save!
      ar_resource.replicas_force!
    end

    render(json: { })
  end

  protected

  def after_create(**args)
    if (!request || !is_param_true?(params[:do_not_replicate])) && ar_resource.kind_of?(Ygg::Core::ReplicaNotifiable)
      ar_resource.replicas_req_notify(notify_obj: ar_resource)
    end
  end

  def after_update(**args)
    if (!request || !is_param_true?(params[:do_not_replicate])) && ar_resource.kind_of?(Ygg::Core::ReplicaNotifiable)
      ar_resource.replicas_req_notify(notify_obj: ar_resource)
    end
  end

  def after_destroy(**args)
    if (!request || !is_param_true?(params[:do_not_replicate])) && ar_resource.kind_of?(Ygg::Core::ReplicaNotifiable)
      ar_resource.replicas_req_notify(notify_obj: ar_resource)
    end
  end

  def transaction_handler(request_id:)
    hel_transaction("Hel operation", request_id: request_id) do |transaction|
      yield
    end
  end
end

end
end
