#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg

class ServiceModel < PublicModel

  self.abstract_class = true

  has_one :agreement_service_instance,
          :class_name => '::Ygg::Shop::Agreement::Service::Instance',
          :as => :service

  has_one :agreement,
          :class_name => '::Ygg::Shop::Agreement',
          :through => :agreement_service_instance

  before_destroy :deactivate_instance

  module Scopes

    def belonging_to(entity)
      case entity
      when Ygg::Core::Person
        joins(:agreement).where{
          (
            ( agreement.customer_id.eq(entity) & (agreement.customer_type.eq(entity.class.name)) ) |
            agreement.signer_id.eq(entity)
         )
        }
      when Ygg::Core::Organization
        joins(:agreement).where{
          ( agreement.customer_id.eq(entity) & (agreement.customer_type.eq(entity.class.name)) )
        }
      end
    end

  end

  extend Scopes


  # Provide a human-recognizable name for the service
  # In this base class it attempts to call #name or #hostname
  #
  # it is supposed to be overridden by child classes in order to provide a meaningful name
  #
  def label
    return name if respond_to? :name
    return hostname if respond_to? :hostname
    id.to_s
  end

  class Interest
    attr_accessor :person
    attr_accessor :tags

    def initialize(**args)
      args.each { |k,v| send("#{k}=", v) }
      @tags = []
    end
  end

  def interested_people

    people = {}

    if agreement.customer.is_a?(Ygg::Core::Person)
      people[agreement.customer] = [ :customer ]
    else
      agreement.customer.organization_people.each do |op|
        people[op.person] = (people[op.person] || []) + [ :customer, "organization_#{op.role}".to_sym ]
      end
    end

#    acl_entries.each do |acl|
#      acl_people = []
#      acl_people << acl.person if acl.person
#      acl_people += acl.group.people if acl.group
#
#      acl_people.each do |person|
#        people[acl.person] = (people[acl.person] || []) + [ :in_acl ]
#      end
#    end

    people
  end

  private
  #######

  #
  # If the service has no provisioner , we consider the instance active
  # as soon it is created
  #
  def stub_activate_instance
    if defined? Ygg::Shop
      agreement_service_instance.force_activation! if
          (agreement_service_instance && agreement_service_instance.new?)
    end
  end

  #
  # This should stay, it provides consistency in case the service is deleted
  # makes sure the relevant agreement instance is closed as well
  #
  def deactivate_instance
    if defined? Ygg::Shop
      agreement_service_instance.force_close! if
          (agreement_service_instance && (agreement_service_instance.ready? || agreement_service_instance.closing?))
    end
  end

end
end
