#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'active_rest/controller'
require 'grafo_store/obj'

module Ygg

#
# main parent class for Ygg models
#
class BasicModel < ActiveRecord::Base
  self.abstract_class = true

  include ActiveRest::Model
  include Ygg::Core::DeepDirty

  include Ygg::Core::HasPornMigration
  include Ygg::Core::HasMetaClass
  include Ygg::Core::HasAcl
  include Ygg::Core::HasIndexCache

  include Ygg::Core::Lifecycle
  include Ygg::Core::Logcollector

 ##############
  include GrafoStore::StorableAsObject

  def attrs_hash
    attributes.symbolize_keys!
  end

  def attrs
    attrs_hash.keys
  end

  class_attribute :gs_rel_map
  self.gs_rel_map = []

  class FilterSyntaxError < RuntimeError ; end

  def calls_to
    AM::Registry[:rails_vos_server]
  end

  def match_filter?(filter)
    filter.all? { |k,v|
      val = send(k)

      if v.is_a?(Hash)
        v.all? { |ft, fv|
          case ft
          when :between
            if val.is_a?(Time) || val.is_a?(Date) || val.is_a?(DateTime)
              fv[0] = Time.parse(fv[0]) if fv[0].is_a?(String)
              fv[1] = Time.parse(fv[1]) if fv[1].is_a?(String)
            end

            val >= fv[0] && val <= fv[1]
          when :gt
            if val.is_a?(Time) || val.is_a?(Date) || val.is_a?(DateTime)
              fv = Time.parse(fv) if fv.is_a?(String)
            end

            val > fv
          when :gte
            if val.is_a?(Time) || val.is_a?(Date) || val.is_a?(DateTime)
              fv = Time.parse(fv) if fv.is_a?(String)
            end

            val >= fv
          when :lt
            if val.is_a?(Time) || val.is_a?(Date) || val.is_a?(DateTime)
              fv = Time.parse(fv) if fv.is_a?(String)
            end

            val < fv
          when :lte
            if val.is_a?(Time) || val.is_a?(Date) || val.is_a?(DateTime)
              fv = Time.parse(fv) if fv.is_a?(String)
            end

            val <= fv
          else
            raise FilterSyntaxError
          end
        }
      else
        val == v
      end
    }
  end

  def multifield_compare(other, sort_order)
    sort_order = { sort_order => :asc } unless sort_order.is_a?(Hash)

    sort_order.each { |k,v|
      a = send(k)
      b = other.send(k)

      if a != b
        return (v == :asc ? (a <=> b) : (b <=> a))
      end
    }

    0
  end

#############

  def self.define_default_log_controller(model)
    cls = Class.new do
      include ActiveRest::Controller

      ar_controller_for model
      self.ar_authorization_required = false
      self.ar_prefix = 'Log'
    end
    const_set 'LogController', cls
  end

  def self.define_default_provisionable_controller(model)
    cls = Class.new do
      include ActiveRest::Controller

      ar_controller_for model
      self.ar_authorization_required = false
      self.ar_prefix = 'Provisioning'

#      remove_attribute(:acl_entries)

      attribute(:version) do
        not_writable!
        ignore!
      end

      view :_default_ do
        self.with_type = false
      end
    end
    const_set 'ProvisioningController', cls
  end

  def self.define_default_provisioning_controller(model)
    cls = Class.new do
      include ActiveRest::Controller

      ar_controller_for model
      self.ar_authorization_required = false
      self.ar_prefix = 'Provisioning'
    end
    const_set 'ProvisioningController', cls
  end

  def self.all_subclasses
    subclasses + subclasses.map { |x| x.all_subclasses }.flatten
  end

  def self.klass
    Ygg::Core::Klass.find_by!(name: self.name)
  end
end

end
