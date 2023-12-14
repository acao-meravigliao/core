#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Organization::RestController < Ygg::Hel::RestController

  ar_controller_for Organization

  member_action :similar_to

  member_action :update_acls
  member_action :invoice_all_pending
  member_action :force_billing_flush
  member_action :similar
  member_action :merge

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:name) { show! }
    attribute(:handle) { show! }
    attribute(:vat_number) { show! }
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

    attribute(:reseller) { show! }

    attribute(:organization_people) do
      attribute(:person) do
        show!
        empty!
        attribute(:id) { show! }
        attribute(:first_name) { show! }
        attribute(:last_name) { show! }
        attribute(:italian_fiscal_code) { show! }
      end
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

  load_role_defs!
  model_has_acl
  default_acl_only_prefilter

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
      filter :not, :ids => { :values => [ i ] }
      size s
    }

    ar_respond_with(res.results.select { |x| x._score > 0.5 }.map { |x| x.load })
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
      ar_resource.ar_apply_update_attributes(:rest, json_request[:updates], :aaa_context => aaa_context)

      ar_resource.merge(json_request[:ids])
    end

    ar_respond_with({})
  end
end

end
end
