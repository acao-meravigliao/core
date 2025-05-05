#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class StatsController < Ygg::Hel::BaseController
  layout false

  def all
    ensure_authenticated!

    raise "Föra di ball" unless aaa_context.has_global_roles?(:superuser)

    data = {
      numero_giorni_di_linea_dell_anno_corrent: Ygg::Acao::RosterDay.for_year.count,
      numero_giorni_di_linea_vuoti: Ygg::Acao::RosterDay.for_year.to_a.select { |x| x.roster_entries.count == 0 }.count,
      numero_giorni_di_linea_non_pieni: Ygg::Acao::RosterDay.for_year.to_a.select { |x| x.roster_entries.count < x.needed_people }.count,
      slot_totali: Ygg::Acao::RosterDay.for_year.sum(:needed_people),
      slot_occupati: Ygg::Acao::RosterDay.for_year.map { |x| x.roster_entries }.flatten.count,
      piloti_iscritti_pagato_senza_tutti_turni: Ygg::Acao::Member.members_for_year.order(:code).to_a.select { |x| !x.roster_needed_entries_present }.map { |x| { code: x.code, name: x.person.name, needed: x.roster_entries_needed, entries: x.roster_entries.map { |y| y.roster_day.date }.sort.map { |y| y.strftime('%Y-%m-%d') } } },
    }

    respond_to do |format|
      format.json { render json: data }
    end
  end
end

end
end
