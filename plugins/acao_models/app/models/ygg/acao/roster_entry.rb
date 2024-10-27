# frozen_string_literal: true
#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class RosterEntry < Ygg::PublicModel
  self.table_name = 'acao.roster_entries'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :roster_day,
             class_name: 'Ygg::Acao::RosterDay'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  after_initialize do
    if new_record?
      self.selected_at = Time.now
    end
  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def offer!
    self.on_offer_since = Time.now
    save!
  end

  def offer_cancel!
    self.on_offer_since = nil
    save!
  end

  def offer_accept!(from_person:)
    transaction do
      self.on_offer_since = nil
      self.person = from_person
      # Regenerate ACLs?
      save!

      # Send notification
    end
  end

  def self.status_for_year(member:, year:)
    person = member.person

    res = {
      year: year.year,
    }

    membership = member.memberships.find_by(reference_year: year)

    needed_entries_present = nil
    needed_total = nil
    needed_high_season = nil
    can_select_entries = false
    roster_entries = nil

    if membership && (membership.status == 'MEMBER' || membership.status == 'WAITING_PAYMENT')
      roster_entries_needed = member.roster_entries_needed(year: year.year)
      needed_entries_present = member.roster_needed_entries_present(year: year.year)

      res.merge!(
        can_select_entries: true,
        needed_total: roster_entries_needed[:total],
        needed_high_season: roster_entries_needed[:high_season],
        needed_entries_present: needed_entries_present,
      )
    end

    res
  end
end

end
end
