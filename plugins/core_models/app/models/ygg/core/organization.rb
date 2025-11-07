#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Organization < OrgaPerson

  self.table_name = 'core.organizations'
  self.inheritance_column = false

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  if defined? ShopModels
    include Ygg::Shop::Billable::Organization
  end

  has_handle :handle, from: [ :name ] do |computed, original|
    "O-#{computed}"
  end

  belongs_to :headquarters_location,
             class_name: 'Ygg::Core::Location',
             dependent: :destroy,
             embedded: true,
             autosave: true,
             optional: true

  belongs_to :registered_office_location,
             class_name: 'Ygg::Core::Location',
             dependent: :destroy,
             embedded: true,
             autosave: true,
             optional: true

  belongs_to :invoicing_location,
             class_name: 'Ygg::Core::Location',
             dependent: :destroy,
             embedded: true,
             autosave: true,
             optional: true

  has_many :organization_people,
           class_name: '::Ygg::Core::Organization::Person',
           dependent: :destroy,
           embedded: true,
           autosave: true,
           before_add: lambda { |*args| @association_organization_people_changed = true },
           before_remove: lambda { |*args| @association_organization_people_changed = true }

  has_many :people,
           class_name: '::Ygg::Core::Person',
           through: :organization_people

  has_meta_class
  has_acl

  # has_one :reseller,
  #         :class_name => '::Ygg::Shop::Reseller'

  validates :name, presence: true
#  validates :vat_number, uniqueness: true

  if defined? PgSearch
    include PgSearch::Model
    multisearchable against: [ :name, :vat_number, :italian_fiscal_code, ]

    pg_search_scope :search, ignoring: :accents, against: {
      name: 'A',
      vat_number: 'A',
      italian_fiscal_code: 'A',
    }, using: {
      tsearch: {},
      trigram: { only: [ :name ] },
    }
  end

  before_save do
    @schedule_acl_update ||= deep_changes.has_key?(:organization_people)
  end

  after_save do
    @association_organization_people_changed = false

    if @schedule_acl_update
      update_acls
      @schedule_acl_update = false
    end
  end

  def update_acls
    transaction do
      grants = Hash[organization_people.where('adm_level IS NOT NULL').map { |x| [ x.person_id, "owner_#{x.adm_level.downcase}" ] } ]

      #services.each do |service|
      #  if service.respond_to?(:acl_replace_auto)
      #    service.acl_replace_auto(grants: grants, owner: self)
      #    service.save!
      #  end
      #end
    end

    nil
  end

  def name_for_filename
    name.downcase.gsub('[^-a-z_]','').gsub(' ', '-')
  end

  def merge(other)
    if other.kind_of? Array
      other.each { |x| merge(x) }
      return
    end

    other = Organization.find(other) if !other.kind_of? Organization

    other.name += ' *MERGED*'

    contacts << other.contacts

    package_instances << other.package_instances
    agreements << other.agreements
    agreements_as_invoice_to << other.agreements_as_invoice_to
    invoices << other.invoices
    billing_entries << other.billing_entries

    other.save!
    save!
  end

  def label
    name
  end

  def summary
    name
  end
end

end
end
