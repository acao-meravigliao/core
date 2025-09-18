#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person < OrgaPerson
  self.table_name = 'core.people'
  self.inheritance_column = false

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'first_name',  type: :string, limit: 64, null: false } ],
    [ :must_have_column, { name: 'last_name',   type: :string, limit: 64, null: false } ],
    [ :must_have_column, { name: 'middle_name', type: :string, limit: 64 } ],
    [ :must_have_column, { name: 'nickname', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'gender', type: :string, limit: 1 } ],
    [ :must_have_column, { name: 'residence_location_id', type: :integer } ],
    [ :must_have_column, { name: 'birth_date', type: :datetime } ],
    [ :must_have_column, { name: 'birth_location_id', type: :integer } ],
    [ :must_have_column, { name: 'id_document_type', type: :string } ],
    [ :must_have_column, { name: 'id_document_number', type: :string } ],
    [ :must_have_column, { name: 'invoicing_location_id', type: :integer } ],
    [ :must_have_column, { name: 'vat_number', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'italian_fiscal_code', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'sdi_code', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'notes', type: :text } ],
    [ :must_have_column, { name: 'title', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'handle', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'reseller_id', type: :integer } ],
    [ :must_have_column, { name: 'preferred_language_id', type: :integer } ],
    [ :must_have_column, { name: 'invoice_profile_id', type: :integer } ],
    [ :must_have_column, { name: 'invoice_last', type: :datetime } ],
    [ :must_have_column, { name: 'invoice_months', type: :integer } ],
    [ :must_have_column, { name: 'invoice_ceiling', type: :decimal, scale: 6, precision: 14 } ],
    [ :must_have_column, { name: 'invoice_floor', type: :decimal, scale: 6, precision: 14 } ],

    [ :must_have_fk, {to_table: "core.locations", column: "birth_location_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "core.locations", column: "invoicing_location_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "i18n_languages", column: "preferred_language_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "core.locations", column: "residence_location_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  if defined? ShopModels
    include Ygg::Shop::Billable
    include Ygg::Shop::Billable::Person
  end

  if defined? Ygg::I18n
    belongs_to :preferred_language,
               class_name: 'Ygg::I18n::Language',
               optional: true
  end

  has_handle :handle, from: [ :first_name, :last_name ] do |computed, original|
    "P-#{computed}"
  end

  has_many :contacts,
           class_name: '::Ygg::Core::Person::Contact',
           dependent: :destroy,
           embedded: true,
           autosave: true,
           foreign_key: :person_id

  has_many :credentials,
           class_name: '::Ygg::Core::Person::Credential',
           dependent: :destroy,
           embedded: true,
           autosave: true,
           foreign_key: :person_id

  has_many :obfuscated_password_credentials,
           class_name: 'Ygg::Core::Person::Credential::ObfuscatedPassword',
           dependent: :destroy,
           embedded: true,
           autosave: true,
           foreign_key: :person_id

  has_many :person_roles,
           class_name: '::Ygg::Core::Person::Role',
           dependent: :destroy,
           embedded: true,
           autosave: true,
           foreign_key: :person_id

  has_many :roles,
           class_name: '::Ygg::Core::GlobalRole',
           source: :global_role,
           through: :person_roles

  has_many :group_members,
           class_name: '::Ygg::Core::Group::Member',
           dependent: :destroy

  has_many :groups,
           class_name: '::Ygg::Core::Group',
           through: :group_members

  belongs_to :birth_location,
             class_name: '::Ygg::Core::Location',
             embedded: true,
             autosave: true,
             optional: true

  belongs_to :residence_location,
             class_name: '::Ygg::Core::Location',
             embedded: true,
             autosave: true,
             optional: true

  belongs_to :invoicing_location,
             class_name: '::Ygg::Core::Location',
             embedded: true,
             autosave: true,
             optional: true

  has_many :log_entries_as_person,
           class_name: '::Ygg::Core::LogEntry'

#  has_many :realm_operators, class_name: '::Ygg::Sevio::Realm::Operator'
#  has_many :realms, through: :realm_operators

#  has_many :notifications_as_target,
#           class_name: '::Ygg::Core::Notification'

  has_many :person_organizations,
           class_name: '::Ygg::Core::Organization::Person',
           dependent: :destroy,
           embedded: true,
           autosave: true

  has_many :organizations,
           class_name: '::Ygg::Core::Organization',
           through: :person_organizations

  has_many :sessions,
           class_name: '::Ygg::Core::Session',
           inverse_of: :auth_person,
           foreign_key: :auth_person_id

#  has_many :accesses, class_name: 'Ygg::Sevio::Access'

  gs_rel_map << { from: :person, to: :contact, to_cls: '::Ygg::Core::Person::Contact', to_key: 'person_id' }
  gs_rel_map << { from: :person, to: :credential, to_cls: '::Ygg::Core::Person::Credential', to_key: 'person_id' }
  gs_rel_map << { from: :person, to: :birth_location, to_cls: '::Ygg::Core::Location', from_key: 'birth_location_id' }
  gs_rel_map << { from: :person, to: :residence_location, to_cls: '::Ygg::Core::Location', from_key: 'residence_location_id' }

  has_meta_class
  has_acl

  validates :first_name, presence: true
  validates :last_name, presence: true

  if defined? PgSearch
    include PgSearch::Model
    multisearchable against: [ :first_name, :middle_name, :last_name, :nickname, :vat_number, :italian_fiscal_code ]

    pg_search_scope :search, ignoring: :accents, against: {
      first_name: 'A',
      middle_name: 'B',
      last_name: 'A',
      nickname: 'A',
      vat_number: 'A',
      italian_fiscal_code: 'A',
    }, using: {
      tsearch: {},
      trigram: { only: [ :first_name, :last_name, :nickname ] },
    }
  end

  def self.search(query)
    (first_name, last_name) = query.split(' ')

    if !last_name
      last_name = first_name
      first_name = nil
    end

    res = Ygg::Core::Person.where('last_name ILIKE ?', last_name.downcase + '%')

    if first_name
      res = res.where('first_name ILIKE ?', first_name.downcase + '%')
    end

    res
  end

  def update_acls
    transaction do
      services.each do |service|
        if service.respond_to?(:acl_replace_auto)
          service.acl_replace_auto(grants: { id => "owner_full" }, owner: self)
          service.save!
        end
      end
    end

    nil
  end

  def name
    [ first_name, middle_name, last_name ].select { |x| x && !x.empty? }.join(' ')
  end

  def name_for_filename
    name.downcase.gsub('[^-a-z_]','').gsub(' ', '-')
  end

  def merge(other)
    if other.kind_of? Array
      other.each { |x| merge(x) }
      return
    end

    other = Person.find(other) if !other.kind_of? Person

    other.first_name += ' *MERGED*'
    other.last_name += ' *MERGED*'

    contacts << other.contacts
    log_entries_as_person << other.log_entries_as_person

    package_instances << other.package_instances
    agreements << other.agreements
    agreements_as_invoice_to << other.agreements_as_invoice_to
    agreements_as_signer << other.agreements_as_signer
    invoices << other.invoices
    billing_entries << other.billing_entries

    other.save!
    save!
  end

  # Returns true if has all the required roles or no role is required
  #
  # roles is an array of role symbols
  #
  def has_global_roles?(check_roles)
    check_roles = (check_roles.respond_to?(:to_set) ? check_roles : [ check_roles ]).to_set

    check_roles.subset?(global_roles)
  end

  def global_roles
    roles.map { |x| x.name.to_sym }.to_set
  end

  def first_matching_credential(fqda:, password:)
    credentials.where(fqda: fqda).each do |credential|
      if credential.respond_to?(:match_by_password) && credential.match_by_password(password)
        return credential
      end
    end

    return nil
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
