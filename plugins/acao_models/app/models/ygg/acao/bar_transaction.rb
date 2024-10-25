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

    merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_logbar <=> r.old_id },
    l_to_r: lambda { |l|
      puts "LOGBAR ADD #{l.id_logbar}" if debug >= 1

      Ygg::Acao::BarTransaction.create!(
        member: Ygg::Acao::Member.find_by!(code: l.codice_socio),
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

    merge(
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
