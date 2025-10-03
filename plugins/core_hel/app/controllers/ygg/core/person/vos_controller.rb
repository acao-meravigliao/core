#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Core

class Person::VosController < Ygg::Hel::VosBaseController
  def search(query:)
    if query.to_i != 0
      res = Ygg::Acao::Member.find_by(code: query.to_i)
      return [search_repr(res.person)] if res
    end

    res = Ygg::Core::Person.search(query)
    return res.map { |x| search_repr(x) }
  end

  def search_repr(obj)
   {
    id: obj.id,
    first_name: obj.first_name,
    last_name: obj.last_name,
    acao_member_id: obj.acao_member.id,
    acao_code: obj.acao_member.code,
   }
  end
end

end
end
