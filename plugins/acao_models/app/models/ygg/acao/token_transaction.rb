# frozen_string_literal: true
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

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :aircraft,
             class_name: '::Ygg::Acao::Aircraft',
             optional: true

  belongs_to :flight,
             class_name: '::Ygg::Acao::Flight',
             optional: true

  gs_rel_map << { from: :token_transaction, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :token_transaction, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }
  gs_rel_map << { from: :token_transaction, to: :flight, to_cls: 'Ygg::Acao::Flight', from_key: 'flight_id', }

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

    aircraft_cache = Hash[Ygg::Acao::Aircraft.all.map { |x| [ x.registration, x ] } ]

    l_relation = Ygg::Acao::MainDb::LogBollini.all.order(id_log_bollini: :asc)
    l_relation = l_relation.where('id_log_bollini >= ?', start) if start
    l_relation = l_relation.where('id_log_bollini <= ?', stop) if stop

    r_relation = Ygg::Acao::TokenTransaction.
                   includes(:aircraft).
                   where('old_id IS NOT NULL').
                   order(old_id: :asc)
    r_relation = r_relation.where('old_id >= ?', start) if start
    r_relation = r_relation.where('old_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_log_bollini <=> r.old_id },
    l_to_r: lambda { |l|
      puts "LOGBOL ADD #{l.id_log_bollini}" if debug >= 1

      member = Ygg::Acao::Member.find_by(code: l.codice_pilota)
      if !member
        puts "LOGBOL MISSING MEMBER #{l.codice_pilota}!!!! NOT SYNCING ROW"
        return
      end

      aircraft_reg = l.marche_mezzo.strip.upcase
      aircraft = nil

      if !aircraft_reg.blank? && aircraft_reg != 'NO'
        aircraft = aircraft_cache[aircraft_reg]
        if !aircraft
          puts "LOGBOL MISSING AIRCRAFT #{aircraft_reg}"
        end
      end

      Ygg::Acao::TokenTransaction.create(
        member: member,
        recorded_at: troiano_datetime_to_utc(l.log_data),
        old_operator: l.operatore.strip,
        old_marche_mezzo: l.marche_mezzo.strip,
        descr: l.note.strip,
        amount: l.credito_att - l.credito_prec,
        prev_credit: l.credito_prec,
        credit: l.credito_att,
        old_id: l.id_log_bollini,
        aircraft: aircraft,
      )

    },
    r_to_l: lambda { |r|
      puts "LOGBOL DESTROY #{r.old_id}" #if debug >= 1
#      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "LOGBOL CMP #{l.id_log_bollini}" if debug >= 3

      aircraft_reg = l.marche_mezzo.strip.upcase
      aircraft = nil

      if !aircraft_reg.blank? && aircraft_reg != 'NO'
        aircraft = aircraft_cache[aircraft_reg]
        if !aircraft
          puts "LOGBOL MISSING AIRCRAFT #{aircraft_reg}"
        end
      end

      r.assign_attributes(
        amount: l.credito_att - l.credito_prec,
        recorded_at: troiano_datetime_to_utc(l.log_data),
        aircraft: aircraft,
        flight: Ygg::Acao::Flight.find_by(source_id: l.id_volo, source_expansion: 'GL'),
      )

      if r.deep_changed?
        puts "UPDATING LOG BOLLINI old_cassetta_id=#{l.id_log_bollini}" if debug >= 1
        puts r.deep_changes.awesome_inspect(plain: true)
        r.save!
      end
    })

  end

  def self.troiano_datetime_to_utc(dt)
    ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end
end

end
end
