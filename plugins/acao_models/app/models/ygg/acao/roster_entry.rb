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

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :integer, null: false, limit: 4 } ],
    [ :must_have_column, { name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "chief", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "roster_day_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "selected_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "on_offer_since", type: :datetime, default: nil, null: true}],
    [ :must_have_index, {columns: ["uuid"], unique: true}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["roster_day_id"], unique: false}],
    [ :must_have_index, {columns: ["person_id", "roster_day_id"], unique: true}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_roster_days", column: "roster_day_id", primary_key: "id", on_delete: :cascade, on_update: nil}],
  ]

  belongs_to :person,
             class_name: 'Ygg::Core::Person'

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

  def self.status_for_year(person:, year:)
    person = person.becomes(Ygg::Acao::Pilot)

    res = {
      year: year.year,
    }

    membership = person.acao_memberships.find_by(reference_year: year)

    needed_entries_present = nil
    needed_total = nil
    needed_high_season = nil
    can_select_entries = false
    roster_entries = nil

    if membership && (membership.status == 'MEMBER' || membership.status == 'WAITING_PAYMENT')
      roster_entries_needed = person.roster_entries_needed(year: year.year)
      needed_entries_present = person.roster_needed_entries_present(year: year.year)

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
