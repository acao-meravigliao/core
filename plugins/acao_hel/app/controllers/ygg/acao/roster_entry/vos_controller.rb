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

class RosterEntry::VosController
  def compute_status(session:)
    member = session.auth_person.acao_member

    current_year = Ygg::Acao::Year.find_by(year: Time.new.year)
    next_year = Ygg::Acao::Year.renewal_year

    res = {}

    if current_year
      res[:current] = Ygg::Acao::RosterEntry.status_for_year(member: member, year: current_year)
    end

    if next_year && next_year != current_year
      res[:next] = Ygg::Acao::RosterEntry.status_for_year(member: member, year: next_year)
    end

    res
  end
end

end
end
