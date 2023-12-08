#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person::RestController < Ygg::Hel::RestController

  ar_controller_for Ygg::Core::Person

  member_action :current
  member_action :similar_to

  member_action :update_acls
  member_action :invoice_all_pending
  member_action :force_billing_flush
  member_action :change_password
  member_action :similar
  member_action :merge

  attribute(:credentials, type: :polymorphic_models_collection) do
    self.support_class = 'Ygg::Core::Person::Credential'

    self.model_classes = [
      'Ygg::Core::Person::Credential::ObfuscatedPassword',
      'Ygg::Core::Person::Credential::HashedPassword',
      'Ygg::Core::Person::Credential::X509Certificate',
    ]
  end

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:handle) { show! }
    attribute(:first_name) { show! }
    attribute(:last_name) { show! }
    attribute(:italian_fiscal_code) { show! }
  end

  view :edit do
    self.with_perms = true

#    attribute :acl_entries do
#      show!
#      attribute :group do
#        show!
#        empty!
#        attribute(:name) { show! }
#      end
#      attribute :person do
#        show!
#        empty!
#        attribute(:first_name) { show! }
#        attribute(:last_name) { show! }
#        attribute(:handle) { show! }
#        attribute(:italian_fiscal_code) { show! }
#      end
#    end

    attribute(:credentials) do
      show!
    end

    attribute(:reseller) do
      show!
    end

    attribute(:person_roles) do
      attribute(:global_role) do
        show!
      end
    end

    attribute(:contacts) do
      show!
    end
  end

  view :with_packages do
    attribute(:package_instances) do
      show!
      attribute(:package) do
        show!
      end

      attribute(:agreements) do
        show!
        attribute(:service_instances) do
        end

        attribute(:product_revision) do
          show!
          attribute(:product) do
            show!
            attribute(:name) { show! }
          end
        end
      end
    end
  end

  view :with_billing do
    attribute(:billing_entries) do
      show!
    end
  end

  view :with_invoices do
    attribute(:invoices) do
      show!
    end
  end

  view :_default_ do
    attribute(:contacts) do
      show!
    end
  end

  load_role_defs!
  model_has_acl

  def update_acls
    ar_retrieve_resource
    ar_authorize_member_action

    ar_resource.update_acls

    ar_respond_with({})
  end

  def invoice_all_pending
    ar_retrieve_resource
    ar_authorize_member_action

    ar_respond_with(ar_resource.generate_invoice_if_pending!)
  end

  def force_billing_flush
    ar_retrieve_resource
    ar_authorize_member_action

    ar_respond_with(ar_resource.force_billing_flush!)
  end

  def similar
    ar_retrieve_resource
    ar_authorize_member_action

    q = ar_resource.name
    i = ar_resource.id
    s = params[:limit]

    res = ar_model.search {
      query { string q }
      filter :not, ids: { values: [ i ] }
      size s
    }

    ar_respond_with(res.results.select { |x| x._score > 0.5 }.map { |x| x.load })
  end

  def current
    ar_respond_with(aaa_context.auth_person)
  end

  def similar_to
    ar_authorize_collection_action

    q = params[:name]

    res = ar_model.search {
      query { string q }
    }

    ar_respond_with(res.results.select { |x| x._score > 0.5 }.map { |x| x.load })
  end

  def merge
    ar_retrieve_resource
    ar_authorize_member_action

    hel_transaction('Merged') do |transaction|
      ar_resource.ar_apply_update_attributes(:rest, json_request[:updates], aaa_context: aaa_context)

      ar_resource.merge(json_request[:ids])
    end

    ar_respond_with({})
  end

#  def change_password
#    ar_resource = aaa_context.auth_identity
#    ar_authorize_member_action
#
#    if !ar_resource.get_first_credential_matching_password(params[:old_password])
#      raise "Wrong Password"
#    end
#
#    if params[:new_password] != params[:new_password2]
#      raise "Passwords do not match"
#    end
#
#    # TODO enforce password quality!
#
#    raise "Password is too short" if params[:new_password].length < 6
#
#    hel_transaction('Password change') do |t|
#      creds = aaa_context.auth_identity.credentials.order(created_at: :desc).to_a.
#                select { |x| x.respond_to?(:match_by_password) }
#      creds[1..-1].each { |x| x.destroy! }
#
#      creds[0].password = params[:new_password]
#      creds[0].save!
#    end
#
#    ar_respond_with(success: true)
#  end

  build_member_roles(:blahblah) do |obj|
    aaa_context &&
    aaa_context.authenticated? &&
    aaa_context.auth_person == obj ? [ :owner ] : []
  end
end

end
end
