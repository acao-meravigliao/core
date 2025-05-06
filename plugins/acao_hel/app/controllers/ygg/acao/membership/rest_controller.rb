#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Membership::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::Membership

  load_role_defs!

  collection_action :renew

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:uuid) { show! }
    attribute(:status) { show! }
    attribute(:valid_from) { show! }
    attribute(:valid_to) { show! }

    attribute(:reference_year) do
      attribute(:year) { show! }
    end

    attribute(:person) do
      show!
      empty!
      attribute(:first_name) { show! }
      attribute(:last_name) { show! }
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:reference_year) do
      attribute(:year) { show! }
    end

#    attribute(:invoice_detail) do
#      show!
#      attribute(:invoice) do
#        show!
#      end
#    end

    attribute :acl_entries do
      show!
      attribute :group do
        show!
        empty!
        attribute(:name) { show! }
      end
      attribute :person do
        show!
        empty!
        attribute(:first_name) { show! }
        attribute(:last_name) { show! }
        attribute(:handle) { show! }
        attribute(:italian_fiscal_code) { show! }
      end
    end
  end

  view :_default_ do
    attribute :invoice_detail do
      show!
    end

    attribute :reference_year do
      show!
    end
  end


  def authorization_prefilter
    ar_model.where(person_id: aaa_context.auth_person.id)
  end

  build_member_roles(:blahblah) do |obj|
     aaa_context.auth_person.id == obj.person_id ? [ :owner ] : []
  end

  def renew_context
    person = aaa_context.auth_person
    current_year = Ygg::Acao::Year.find_by(year: Time.now.year)
    next_year = Ygg::Acao::Year.find_by(year: Time.now.year + 1)

    res = {}

    if current_year
      res[current_year.year] = {
        year: current_year.year,
        year_id: current_year.id,
        announce_time: current_year.renew_announce_time,
        opening_time: current_year.renew_opening_time,
        blocked: person.acao_debtor,
        services: Ygg::Acao::Membership.determine_base_services(person: person, year: current_year),
      }
    end

    if next_year
      res[next_year.year] = {
        year: next_year.year,
        year_id: next_year.id,
        announce_time: next_year.renew_announce_time,
        opening_time: next_year.renew_opening_time,
        blocked: person.acao_debtor,
        services: Ygg::Acao::Membership.determine_base_services(person: person, year: next_year),
      }
    end

    render(json: res)
  end

  def renew_do
    membership = nil

    puts "=========== Membership RENEW ================================================"
    puts json_request
    puts "============================================================================="

    # FIXME Check if acao_person is not null

    hel_transaction('Membership renewal wizard') do
      membership = Ygg::Acao::Membership.renew(
        acao_person: aaa_context.auth_person.acao_person,
        payment_method: json_request[:payment_method],
        enable_email: json_request[:enable_email],
        services: json_request[:services],
        selected_roster_days: json_request[:selected_roster_days],
      )
    end

    render(json: {
      payment_id: membership.invoice_detail.invoice.payments.first.id,
    })
  end
end

end
end
