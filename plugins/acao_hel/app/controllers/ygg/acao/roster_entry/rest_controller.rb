#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Acao

class RosterEntry::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::RosterEntry

  load_role_defs!

  collection_action :status

  member_action :offer
  member_action :offer_cancel
  member_action :offer_accept

  view :grid do
    empty!

    attribute(:id) { show! }
    attribute(:uuid) { show! }
    attribute(:chief) { show! }
    attribute(:selected_at) { show! }

    attribute :roster_day do
      show!
    end

    attribute :person do
      show!
      empty!
      attribute(:first_name) { show! }
      attribute(:last_name) { show! }
    end
  end

  view :edit do
    attribute :roster_day do
      show!
    end

    attribute :person do
      show!
    end
  end

  view :with_days do
    attribute :roster_day do
      show!
    end

    attribute :person do
      show!
    end
  end

  def authorization_prefilter
    ar_model.where(person_id: aaa_context.auth_person.id)
  end

  build_member_roles(:blahblah) do |obj|
    (aaa_context &&
    aaa_context.authenticated? &&
    aaa_context.auth_person.id == obj.person_id) ? [ :owner ] : []
  end

  def ar_apply_filter(rel, filter)
    if filter['today']
      (attr, path) = rel.nested_attribute('roster_day.date')
      rel = rel.joins(path[0..-1].reverse.inject { |a,x| { x => a } }) if path.any?
      rel = rel.where(attr.eq(Time.now))
    else
      rel = rel.where(filter)
    end

    rel
  end

  def before_create(resource:, resource_object:, **args)
    # TODO, calculate roles, perms in a "Request" object once, at the beginning, and use them here
    roles = ar_collection_roles
    perms = ar_build_perms_from_roles(roles, ar_collection_role_defs)

#    if !attr_writable?(:person, perms: perms)
      resource.person = aaa_context.auth_person
#    end

    # TODO FIXME: check consistency (valid roster_day!)
  end

  def get_status
    person = aaa_context.auth_person

    current_year = Ygg::Acao::Year.find_by(year: Time.new.year)
    next_year = Ygg::Acao::Year.renewal_year

    res = {}

    if current_year
      res[:current] = Ygg::Acao::RosterEntry.status_for_year(person: person, year: current_year)
    end

    if next_year && next_year != current_year
      res[:next] = Ygg::Acao::RosterEntry.status_for_year(person: person, year: next_year)
    end

    ar_respond_with(res)
  end

  def offer
    ar_retrieve_resource
    ar_authorize_member_action(resource: ar_resource, action: :offer)

    hel_transaction('Offered for exchange') do
      ar_resource.offer!
    end

    ar_respond_with({})
  end

  def offer_cancel
    ar_retrieve_resource
    ar_authorize_member_action(resource: ar_resource, action: :offer_cancel)

    hel_transaction('Exchange offer canceled') do
      ar_resource.offer_cancel!
    end

    ar_respond_with({})
  end

  def offer_accept
    ar_retrieve_resource
    ar_authorize_member_action(resource: ar_resource, action: :offer_accept)

    hel_transaction('Exchange offer accepted') do
      ar_resource.offer_accept!(from_user: aaa_context.auth_person)
    end

    ar_respond_with({})
  end
end

end
end
