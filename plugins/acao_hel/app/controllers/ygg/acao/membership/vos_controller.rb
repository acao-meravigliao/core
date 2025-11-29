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

  def renew_context(year:, **)
    ensure_authenticated!

    person = session.auth_person
    member = person.acao_member
    year = Ygg::Acao::Year.find_by!(year: year)

    return {
      blocked: member.debtor,
      base_services: Ygg::Acao::Membership.determine_base_services(member: member, year_model: year),
    }
  end
end

end
end
