#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class TokenTransaction < Ygg::PublicModel
  self.table_name = 'acao.token_transactions'

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :integer, null: false, limit: 4 } ],
    [ :must_have_column, { name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "aircraft_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "recorded_at", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "prev_credit", type: :decimal, default: nil, precision: 14, scale: 6, null: true}],
    [ :must_have_column, {name: "credit", type: :decimal, default: nil, precision: 14, scale: 6, null: true}],
    [ :must_have_column, {name: "amount", type: :decimal, default: nil, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "session_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_index, {columns: ["uuid"], unique: true}],
    [ :must_have_index, {columns: ["recorded_at"], unique: false}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["aircraft_id"], unique: false}],
    [ :must_have_index, {columns: ["session_id"], unique: false}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "core_sessions", column: "session_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_aircrafts", column: "aircraft_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :person,
             class_name: '::Ygg::Core::Person'

  belongs_to :aircraft,
             class_name: '::Ygg::Acao::Aircraft',
             optional: true

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]


  def self.sync_from_maindb!(from_time: nil, start: nil, stop: nil, debug: 0)
    if from_time
      ff = Ygg::Acao::MainDb::LogBollini.order(log_data: :asc).where('log_data > ?', from_time).first
      return if !ff
      start = ff.id_log_bollini
    end

    l_relation = Ygg::Acao::MainDb::LogBollini.all.order(id_log_bollini: :asc)
    l_relation = l_relation.where('id_log_bollini >= ?', start) if start
    l_relation = l_relation.where('id_log_bollini <= ?', stop) if stop

    r_relation = Ygg::Acao::TokenTransaction.
                   where('old_id IS NOT NULL').
                   order(old_id: :asc)
    r_relation = r_relation.where('old_id >= ?', start) if start
    r_relation = r_relation.where('old_id <= ?', stop) if stop

    merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_log_bollini <=> r.old_id },
    l_to_r: lambda { |l|
      aircraft_reg = l.marche_mezzo.strip.upcase
      aircraft_reg = nil if aircraft_reg == 'NO' || aircraft_reg.blank?

      puts "LOGBOL #{l.id_log_bollini}" if debug >= 1

      Ygg::Acao::TokenTransaction.create(
        person: Ygg::Acao::Pilot.find_by!(acao_code: l.codice_pilota),
        recorded_at: troiano_datetime_to_utc(l.log_data),
        old_operator: l.operatore.strip,
        old_marche_mezzo: l.marche_mezzo.strip,
        descr: l.note.strip,
        amount: l.credito_att - l.credito_prec,
        prev_credit: l.credito_prec,
        credit: l.credito_att,
        old_id: l.id_log_bollini,
        aircraft: Ygg::Acao::Aircraft.find_by(registration: aircraft_reg),
      )

    },
    r_to_l: lambda { |r|
      puts "LOGBOL DESTROY #{r.old_id}" #if debug >= 1
#      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "LOGBOL CMP #{l.id_log_bollini}" if debug >= 3

      aircraft_reg = l.marche_mezzo.strip.upcase
      aircraft_reg = nil if aircraft_reg == 'NO' || aircraft_reg.blank?

      r.assign_attributes(
        amount: l.credito_att - l.credito_prec,
        recorded_at: troiano_datetime_to_utc(l.log_data),
        aircraft: Ygg::Acao::Aircraft.find_by(registration: aircraft_reg),
      )

      if r.deep_changed?
        puts "UPDATING LOG BOLLINI old_cassetta_id=#{l.id_log_bollini}" if debug >= 1
        puts r.deep_changes.awesome_inspect(plain: true)
        r.save!
      end
    })

  end

  def self.merge(l:, r:, l_cmp_r:, l_to_r:, r_to_l:, lr_update:)
    r_enum = r.each
    l_enum = l.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && l_cmp_r.call(l, r) == 1)
        r_to_l.call(r)

        r = r_enum.next rescue nil
      elsif !r || (l &&  l_cmp_r.call(l, r) == -1)
        l_to_r.call(l)

        l = l_enum.next rescue nil
      else
        lr_update.call(l, r)

        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end
  end

  def self.troiano_datetime_to_utc(dt)
    ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end

  def self.merge(l:, r:, l_cmp_r:, l_to_r:, r_to_l:, lr_update:)
    r_enum = r.each
    l_enum = l.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && l_cmp_r.call(l, r) == 1)
        r_to_l.call(r)

        r = r_enum.next rescue nil
      elsif !r || (l &&  l_cmp_r.call(l, r) == -1)
        l_to_r.call(l)

        l = l_enum.next rescue nil
      else
        lr_update.call(l, r)

        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end
  end

end

end
end
