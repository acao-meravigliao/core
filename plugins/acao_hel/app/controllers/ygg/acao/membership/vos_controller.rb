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

class Membership::VosController < Ygg::Hel::VosBaseController

  def renew_context(year:)
    ensure_authenticated!

    person = session.auth_person
    member = person.acao_member
    year = Ygg::Acao::Year.find_by(year: year)

    return {
      blocked: member.debtor,
      base_services: Ygg::Acao::Membership.determine_base_services(member: member, year: year),
    }
  end



#  def create(obj:)
#    ensure_authenticated!
#    raise AuthorizationError unless session.has_global_roles?(:superuser)
#
#    new_obj = nil
#
#    ActiveRecord::Base.connection_pool.with_connection do
#      ActiveRecord::Base.transaction do
#        new_obj = Ygg::Acao::RosterEntry.create(
#          member: Ygg::Acao::Member.find(obj[:member_id]),
#          roster_day: Ygg::Acao::RosterDay.find(obj[:roster_day_id]),
#        )
#      end
#    end
#
#    ds.tell(::AM::GrafoStore::Store::MsgObjectCreate.new(
#      obj: new_obj,
#      rels: [
#        { from_as: :roster_entry, to_as: :member, to: new_obj.member_id },
#        { from_as: :entry, to_as: :day, to: new_obj.roster_day_id },
#      ]
#    ))
#  end
#
#  def move(obj:, to_day_id:)
#    old_day_id = obj.roster_day_id
#
#    obj.roster_day_id = to_day_id
#    obj.save!
#
#    ds.tell(::AM::GrafoStore::Store::MsgRelationDestroy.new(
#      a_as: :entry, a: obj.id,
#      b_as: :day, b: old_day_id,
#    ))
#
#    ds.tell(::AM::GrafoStore::Store::MsgRelationCreate.new(
#      a_as: :entry, a: obj.id,
#      b_as: :day, b: to_day_id,
#    ))
#  end
#
#  def destroy(obj:)
#    ds.tell(::AM::GrafoStore::Store::MsgObjectDestroy.new(id: obj.id))
#
#    obj.destroy!
#  end
#
#  def compute_status()
#    member = session.auth_person.acao_member
#
#    current_year = Ygg::Acao::Year.find_by(year: Time.new.year)
#    next_year = Ygg::Acao::Year.renewal_year
#
#    res = {}
#
#    if current_year
#      res[:current] = Ygg::Acao::RosterEntry.status_for_year(member: member, year: current_year)
#    end
#
#    if next_year && next_year != current_year
#      res[:next] = Ygg::Acao::RosterEntry.status_for_year(member: member, year: next_year)
#    end
#
#    res
#  end
end

end
end
