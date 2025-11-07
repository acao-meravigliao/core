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

class BarTransaction < Ygg::PublicModel
  self.table_name = 'acao.bar_transactions'

  belongs_to :member,
             class_name: '::Ygg::Acao::Member'

  belongs_to :operator,
             class_name: 'Ygg::Acao::Member',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)

#  include Ygg::Core::Notifiable
#
#  def set_default_acl
#    transaction do
#      acl_entries.where(owner: self).destroy_all
#      acl_entries << AclEntry.new(owner: self, person: person, capability: 'owner')
#    end
#  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def self.one_payment_has_been_completed!(payment:)
    if Rails.application.config.acao.bar_add_maindb_transaction
      Ygg::Acao::MainDb::LogBar2.transaction do
        mdb = Ygg::Acao::MainDb::Socio.find_by!(codice_socio_dati_generale: payment.member.code)
        visita = mdb.visita
        visita.lock!

        #Ygg::Acao::MainDb::LogBar2.create!(
        #  data_reg: Time.now,
        #  descrizione: "Accredito da pagamento SatiSpay #{payment.identifier}",
        #  codice_socio: payment.member.code,
        #  prezzo: payment.amount,
        #  credito_prec: visita.acconto_bar_euro,
        #  credito_rim: visita.acconto_bar_euro + payment.amount,
        #)

        Ygg::Acao::MainDb::CassettaBarLocale.create!(
          data_reg: Time.now,
          avere_cassa_bar_locale: payment.amount,
          dare_cassa_bar_locale: 0,
          causale: "Accredito da pagamento SatiSpay #{payment.identifier}",
          codice: payment.member.code,
          note: "Pagamento con SatisPay #{payment.identifier}",
        )

        visita.acconto_bar_euro = visita.acconto_bar_euro + payment.amount,
        visita.save!
      end
    else
      transaction do
        payment.member.lock!

        create!(
          member: payment.member,
          recorded_at: Time.now,
          descr: "Accredito da pagamento SatiSpay #{payment.identifier}",
          prev_credit: payment.member.bar_credit,
          credit: payment.member.bar_credit + payment.amount,
          amount: payment.amount,
          cnt: 1,
          unit: '€',
        )

        payment.member.bar_credit += payment.amount
        payment.member.save!
      end
    end
  end

  def self.sync_from_maindb!(from_time: nil, start: nil, stop: nil, debug: 0)
    if from_time
      ff = Ygg::Acao::MainDb::LogBar2.order(data_reg: :asc).where('data_reg > ?', from_time).first
      return if !ff
      start = ff.id_logbar
    end

    l_relation = Ygg::Acao::MainDb::LogBar2.all.order(id_logbar: :asc)
    l_relation = l_relation.where('id_logbar >= ?', start) if start
    l_relation = l_relation.where('id_logbar <= ?', stop) if stop

    r_relation = Ygg::Acao::BarTransaction.
                   where('old_id IS NOT NULL').
                   order(old_id: :asc)
    r_relation = r_relation.where('old_id >= ?', start) if start
    r_relation = r_relation.where('old_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_logbar <=> r.old_id },
    l_to_r: lambda { |l|
      puts "LOGBAR ADD #{l.id_logbar}" if debug >= 1

      member = Ygg::Acao::Member.find_by(code: l.codice_socio)
      if !member
        puts "LOGBAR MISSING MEMBER #{l.codice_socio}!!!! NOT SYNCING ROW"
        return
      end

      Ygg::Acao::BarTransaction.create!(
        member: member,
        recorded_at: troiano_datetime_to_utc(l.data_reg),
        cnt: 1,
        unit: '€',
        descr: l.descrizione.strip,
        amount: -l.prezzo,
        prev_credit: l.credito_prec,
        credit: l.credito_rim,
        old_id: l.id_logbar,
      )
    },
    r_to_l: lambda { |r|
      puts "LOGBAR DESTROY #{r.old_id}" #if debug >= 1
#      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "LOGBAR CMP #{l.id_logbar}" if debug >= 3

        r.assign_attributes(
          recorded_at: troiano_datetime_to_utc(l.data_reg),
        )

        if r.deep_changed?
          puts "LOGBAR UPDATE id_logbar=#{l.id_logbar}"
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
    })
  end

  def self.sync_from_maindb2!(from_time: nil, start: nil, stop: nil, debug: 0)
    if from_time
      ff = Ygg::Acao::MainDb::CassettaBarLocale.order(data_reg: :asc).where('data_reg > ?', from_time).first
      return if !ff
      start = ff.id_cassetta_bar_locale
    end

    l_relation = Ygg::Acao::MainDb::CassettaBarLocale.all.order(id_cassetta_bar_locale: :asc)
    l_relation = l_relation.where('id_cassetta_bar_locale >= ?', start) if start
    l_relation = l_relation.where('id_cassetta_bar_locale <= ?', stop) if stop

    r_relation = Ygg::Acao::BarTransaction.
                   where('old_cassetta_id IS NOT NULL').
                   order(old_cassetta_id: :asc)
    r_relation = r_relation.where('old_cassetta_id >= ?', start) if start
    r_relation = r_relation.where('old_cassetta_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_cassetta_bar_locale <=> r.old_cassetta_id },
    l_to_r: lambda { |l|
      puts "LOGBARD ADD #{l.id_cassetta_bar_locale}" if debug >= 1

      Ygg::Acao::BarTransaction.create!(
        member: Ygg::Acao::Member.find_by!(code: l.codice),
        recorded_at: troiano_datetime_to_utc(l.data_reg),
        cnt: 1,
        unit: '€',
        descr: l.causale.strip,
        amount: l.avere_cassa_bar_locale,
        prev_credit: nil,
        credit: nil,
        old_cassetta_id: l.id_cassetta_bar_locale,
      )
    },
    r_to_l: lambda { |r|
      puts "LOGBARD DESTROY #{r.old_cassetta_id}" #if debug >= 1
#      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "LOGBARD CMP #{l.id_cassetta_bar_locale}" if debug >= 3

      r.assign_attributes(
        recorded_at: troiano_datetime_to_utc(l.data_reg),
      )

      if r.deep_changed?
        puts "UPDATING LOG BAR old_cassetta_id=#{l.id_cassetta_bar_locale}"
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
