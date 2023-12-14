#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'active_rest/controller'

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
