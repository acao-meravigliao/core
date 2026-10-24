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

  def update_aircrafts(updates:, **)
    ensure_authenticated!

    person = session.auth_person
    member = person.acao_member

    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA #{updates}"

    updates.each do |update|
      case update[:op]
      when 'ADD'
        ac = Ygg::Acao::Aircraft.find_by(registration: update[:registration])
        if ac
          member.aircraft_owners.create!(aircraft: ac, is_referent: update[:referent])
          ac.parking = update[:parking]
          ac.hangar = update[:parking] == 'HANGAR'
          ac.save!

          if update[:parking] == 'TRAILER_A'
            ac.trailer ||= Ygg::Acao::Trailer.new(
              zone: 'A'
            )
          elsif update[:parking] == 'TRAILER_BC'
            ac.trailer ||= Ygg::Acao::Trailer.new(
              zone: 'B'
            )
          end

        else
          ac = Ygg::Acao::Aircraft.create!(
            registration: update[:registration],
            flyable: true,
            is_towplane: false,
            reserved: false,
            parking: update[:parking],
            hangar: update[:parking] == 'HANGAR',
          )
        end

      when 'UPDATE'
        member_ac = member.aircraft_owners.find_by(aircraft_id: update[:id])
        member_ac.is_referent = update[:referent]
        member_ac.save!

        ac = member_ac.aircraft
        ac.parking = update[:parking]
        ac.hangar = update[:parking] == 'HANGAR'
        ac.save!

        if update[:parking] == 'TRAILER_A'
          ac.trailer ||= Ygg::Acao::Trailer.new(
            zone: 'A'
          )
        elsif update[:parking] == 'TRAILER_BC'
          ac.trailer ||= Ygg::Acao::Trailer.new(
            zone: 'B'
          )
        end

      when 'REMOVE'
        member_ac = member.aircraft_owners.find_by(aircraft_id: update[:id])
        member_ac.destroy
      end
    end
  end

  def extra_services(year:, **)
    ensure_authenticated!

    person = session.auth_person
    member = person.acao_member
    year = Ygg::Acao::Year.find_by!(year: year)

    return Ygg::Acao::Membership.determine_extra_services(member: member, year_model: year)
  end


end

end
end
