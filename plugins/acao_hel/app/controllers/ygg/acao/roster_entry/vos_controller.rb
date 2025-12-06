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

class RosterEntry::VosController < Ygg::Hel::VosBaseController
  def create(body:, **)
    ensure_authenticated!
    raise AuthorizationError unless session.has_global_roles?(:superuser)

    new_obj = nil

    ds.tell(::AM::GrafoStore::Store::MsgObjectCreate.new(
      obj: new_obj,
      rels: [
        { from_as: :roster_entry, to_as: :member, to: new_obj.member_id },
        { from_as: :entry, to_as: :day, to: new_obj.roster_day_id },
      ]
    ))
  end

  def move(obj:, to_day_id:, **)
    old_day_id = obj.roster_day_id

    obj.roster_day_id = to_day_id
    obj.save!

    ds.tell(::AM::GrafoStore::Store::MsgRelationDestroy.new(
      a_as: :entry, a: obj.id,
      b_as: :day, b: old_day_id,
    ))

    ds.tell(::AM::GrafoStore::Store::MsgRelationCreate.new(
      a_as: :entry, a: obj.id,
      b_as: :day, b: to_day_id,
    ))
  end

  def destroy(obj:, **)
    ds.tell(::AM::GrafoStore::Store::MsgObjectDestroy.new(id: obj.id))
  end
end

end
end
