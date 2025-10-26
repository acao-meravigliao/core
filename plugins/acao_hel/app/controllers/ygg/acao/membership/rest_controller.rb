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
#    attribute :invoice_detail do
#      show!
#    end

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
        services: Ygg::Acao::Membership.determine_base_services(person: person, year_model: current_year),
      }
    end

    if next_year
      res[next_year.year] = {
        year: next_year.year,
        year_id: next_year.id,
        announce_time: next_year.renew_announce_time,
        opening_time: next_year.renew_opening_time,
        blocked: person.acao_debtor,
        services: Ygg::Acao::Membership.determine_base_services(person: person, year_model: next_year),
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
      member = aaa_context.auth_person.acao_member

      member.assign_attributes(
        email_allowed: json_request[:email_allowed],
        privacy_accepted: json_request[:privacy_accepted],
        consent_association: json_request[:consent_association],
        consent_surveillance: json_request[:consent_surveillance],
        consent_accessory: json_request[:consent_accessory],
        consent_profiling: json_request[:consent_profiling],
        consent_magazine: json_request[:consent_magazine],
        consent_fai: json_request[:consent_fai],
        consent_marketing: json_request[:consent_marketing],
      )

      if json_request[:email_allowed]
        member.email_allowed_at = Time.now
      end

      if json_request[:privacy_accepted]
        member.privacy_accepted_at = Time.now
      end

      member.save!

      year_model = Ygg::Acao::Year.find_by!(year: json_request[:year])

      # FIXME: consider passpartout ROLE
      #raise "Renewal not open" if Time.now < year_model.renew_opening_time

      membership = Ygg::Acao::Membership.renew(
        member: aaa_context.auth_person.acao_member,
        year_model: year_model,
        services: json_request[:services],
        selected_roster_days: json_request[:selected_roster_days],
      )
    end

    render(json: {
      debt_id: membership.debt_detail.debt.id,
    })
  end
end

end
end
