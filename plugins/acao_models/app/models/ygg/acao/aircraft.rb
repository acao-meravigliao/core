# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Aircraft < Ygg::PublicModel
  self.table_name = 'acao.aircrafts'

  has_one :trailer,
           class_name: 'Ygg::Acao::Trailer'

  belongs_to :aircraft_type,
             class_name: 'Ygg::Acao::AircraftType',
             optional: true

  belongs_to :club,
             class_name: 'Ygg::Acao::Club',
             optional: true

  belongs_to :club_owner,
             class_name: 'Ygg::Acao::Club',
             optional: true

  has_many :owners,
           class_name: 'Ygg::Acao::Aircraft::Owner'

  has_many :flights,
           class_name: 'Ygg::Acao::Flight'

  has_many :token_transactions,
           class_name: 'Ygg::Acao::TokenTransaction'

  has_many :flights,
           class_name: 'Ygg::Acao::Flight'

  has_many :flarmnet_entries,
           class_name: 'Ygg::Acao::FlarmnetEntry'

  has_many :ogn_ddb_entries,
           class_name: 'Ygg::Acao::OgnDdbEntry'

  gs_rel_map << { from: :aircraft, to: :aircraft_owner, to_cls: 'Ygg::Acao::Aircraft::Owner', to_key: 'aircraft_id', }
  gs_rel_map << { from: :aircraft, to: :club, to_cls: 'Ygg::Acao::Club', from_key: 'club_id', }
  gs_rel_map << { from: :aircraft, to: :club_owner, to_cls: 'Ygg::Acao::Club', from_key: 'club_owner_id', }
  gs_rel_map << { from: :aircraft, to: :flight, to_cls: 'Ygg::Acao::Flight', to_key: 'aircraft_id', }
  gs_rel_map << { from: :aircraft, to: :aircraft_type, to_cls: 'Ygg::Acao::AircraftType', from_key: 'aircraft_type_id', }
  gs_rel_map << { from: :aircraft, to: :token_transaction, to_cls: 'Ygg::Acao::TokenTransaction', to_key: 'aircraft_id', }
  gs_rel_map << { from: :aircraft, to: :flarmnet_entry, to_cls: 'Ygg::Acao::FlarmnetEntry', to_key: 'aircraft_id', }
  gs_rel_map << { from: :aircraft, to: :ogn_ddb_entry, to_cls: 'Ygg::Acao::OgnDdbEntry', to_key: 'aircraft_id', }

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
  ]

  after_create do
    associate_flarm_entries
  end

  class IncompatibleRecord < Ygg::Exception
    attr_reader :diffs

    def initialize(diffs:, **args)
      super(**args)

      @diffs = diffs
    end
  end

  def associate_flarm_entries
    fe = Ygg::Acao::FlarmnetEntry.find_by(registration: registration)
    if fe
      fe.aircraft = self
      fe.save!
    end

    fe = Ygg::Acao::FlarmnetEntry.find_by(device_id: flarm_identifier, device_type: 'F')
    if fe
      fe.aircraft = self
      fe.save!
    end

    fe = Ygg::Acao::FlarmnetEntry.find_by(device_id: icao_identifier, device_type: 'I')
    if fe
      fe.aircraft = self
      fe.save!
    end

    fe = Ygg::Acao::OgnDdbEntry.find_by(aircraft_registration: registration)
    if fe
      fe.aircraft = self
      fe.save!
    end

    fe = Ygg::Acao::OgnDdbEntry.find_by(device_id: flarm_identifier, device_type: 'F')
    if fe
      fe.aircraft = self
      fe.save!
    end

    fe = Ygg::Acao::OgnDdbEntry.find_by(device_id: icao_identifier, device_type: 'I')
    if fe
      fe.aircraft = self
      fe.save!
    end
  end

  def self.merge(a, b, override_attrs: [], ignore_attrs: [ :flarm_identifier ])
    attrs = [
      :race_registration,
      :registration,
      :flarm_identifier,
      :icao_identifier,
      :hangar,
      :notes,
      :serial_number,
      :arc_valid_to,
      :insurance_valid_to,
      :club_owner_id,
      :club_id,
      :available,
      :is_towplane,
      :aircraft_type_id,
    ]

    transaction do
      good = a
      bad = b

      if a.flarm_identifier != b.flarm_identifier
        puts "FLARM IDs differ a=#{a.flarm_identifier} b=#{b.flarm_identifier}"

        fea = a.flarmnet_entries.find { |x| x.registration == a.registration }
        feb = b.flarmnet_entries.find { |x| x.registration == b.registration }

        puts "fea=#{fea.inspect} feb=#{feb.inspect}"

        if fea && !feb
        elsif feb && !fea
          good = b
          bad = a
        elsif fea && feb
        else
        end
      else
        good = a
        bad = b
      end

      puts "good=#{good.flarm_identifier} bad=#{bad.flarm_identifier}"

      diffs = {}

      attrs.each do |attr_name|
        our = good.send(attr_name)
        oth = bad.send(attr_name)

        if our.nil? ||
           (our.is_a?(String) && our.empty?)

          good.send("#{attr_name}=", oth)
        elsif !oth.nil? && our != oth && !ignore_attrs.include?(attr_name)
          if override_attrs.include?(attr_name)
            good.send("#{attr_name}=", oth)
          else
            diffs[attr_name] = [ our, oth ]
          end
        end
      end

      if diffs.any?
        raise IncompatibleRecord.new(diffs: diffs)
      end

      #good.flights = bad.flights
      #good.token_transactions = bd.token_transactions
      Ygg::Acao::Flight.where(aircraft: bad).update_all(aircraft_id: good.id)
      Ygg::Acao::TokenTransaction.where(aircraft: bad).update_all(aircraft_id: good.id)

      bad.destroy!
      good.save!
    end
  end

  def self.destroy_unreferenced
    self.where(club_id: nil, club_owner_id: nil).each do |x|
      if x.owners.empty? && x.flights.empty? && x.token_transactions.empty?
        x.destroy
      end
    end
  end

  def self.sync_from_maindb!(debug: 0)

    self.connection.execute('SET CONSTRAINTS ALL DEFERRED')

    dups = Ygg::Acao::MainDb::Mezzo.select('numero_flarm,count(*)').where("numero_flarm <> 'id'").where("numero_flarm <> ''").
                                    group(:numero_flarm).having('count(*) > 1')
    if dups.to_a.any?
      puts "Duplicate aircraft with same flarm identifier!"
      dups.each { |x| puts x.numero_flarm }
      fail
    end

    l_relation = Ygg::Acao::MainDb::Mezzo.where.not('Marche' =>
                    [ '', '1-1001', 'ALZATE', 'BARRO', 'AUTO', 'C.D.F.', 'MISMA',
                      'MOBIL1', 'MOTTAR.', 'NO', 'NOALI', 'TRIVERO', 'VENTUS2',
                      'X-HELI', 'X-SEP', 'X-SLMG', 'X-TMG', 'X-TUG', 'X-ULM',
                      'X-WINCH', 'Y2K', 'SALENA' ]).order(id_mezzi: :asc)

    r_relation = Ygg::Acao::Aircraft.all.where.not(source_id: nil).order(source_id: :asc)

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_mezzi <=> r.source_id },
    l_to_r: lambda { |l|
      puts "AIRCRAFT ADD #{l.id_mezzi} #{l.Marche}" if debug >= 1

      race_registration = if !l.sigla_gara.strip.upcase.blank? &&
                             l.sigla_gara.strip.upcase != 'S'
        l.sigla_gara.strip.upcase
      else
        nil
      end

      flarm_identifier = if !l.numero_flarm.strip.upcase.blank? &&
                            l.numero_flarm.strip.upcase != 'CA2A7' &&
                            l.numero_flarm.strip.upcase != 'ee' &&
                            l.numero_flarm.strip.upcase != '111111'
        l.numero_flarm.strip.upcase
      else
        nil
      end

      ac = Aircraft.find_by(registration: l.Marche.strip.upcase)
      if ac
        ac.source_id = l.id_mezzi
      else
        ac = Aircraft.create!(
          source_id: l.id_mezzi,
          registration: l.Marche.strip.upcase,
          race_registration: race_registration,
          flarm_identifier: flarm_identifier,
          hangar: false,
        )
      end

      if !l.codice_proprietario.blank? &&
          l.codice_proprietario != 0
        owner = Ygg::Acao::Member.find_by(code: l.codice_proprietario)

        ac.owners.find_or_create_by(member: owner) do |o|
          o.is_referent = true
        end
      end

      ac.save!
    },
    r_to_l: lambda { |r|
#      puts "AIRCRAFT DESTROY #{r.source_id} #{r.registration}" if debug >= 1
#      r.destroy!
    },
    lr_update: lambda { |l,r|
      owner = if !l.codice_proprietario.blank? &&
         l.codice_proprietario != 0
        Ygg::Acao::Member.find_by(code: l.codice_proprietario)
      else
         nil
      end

      race_registration = if !l.sigla_gara.strip.upcase.blank? &&
                             l.sigla_gara.strip.upcase != 'S'
                             l.sigla_gara.strip.upcase != '-'
        l.sigla_gara.strip.upcase
      else
        nil
      end

      flarm_identifier = if !l.numero_flarm.strip.upcase.blank? &&
                            l.numero_flarm.strip.upcase != 'CA2A7' &&
                            l.numero_flarm.strip.upcase != 'ee' &&
                            l.numero_flarm.strip.upcase != '111111'
        l.numero_flarm.strip.upcase
      else
        nil
      end

      r.assign_attributes(
        registration: l.Marche.strip.upcase,
        race_registration: race_registration,
        flarm_identifier: flarm_identifier,
        hangar: false,
      )

      if !l.codice_proprietario.blank? &&
          l.codice_proprietario != 0
        owner = Ygg::Acao::Member.find_by(code: l.codice_proprietario)

        r.owners.find_or_create_by(member: owner) do |o|
          o.is_referent = true
        end
      end

      if r.deep_changed?
        puts "AIRCRAFT UPD = #{l.id_mezzi}" if debug >= 1
        puts r.deep_changes.awesome_inspect(plain: true)
        r.save!
      end
    })
  end

  def self.clean_duplicates!
    Ygg::Acao::Aircraft.group(:registration).count.each do |reg, cnt|
      if cnt > 1
        dups = Ygg::Acao::Aircraft.where(registration: reg).to_a

        good = dups.find { |x| x.trailer } || dups.find { |x| x.flarm_identifier } || dups.first

        dups.delete(good)

        dups.each do |dup|
          Ygg::Acao::Flight.where(aircraft: dup).update_all(aircraft_id: good.id)
          Ygg::Acao::TokenTransaction.where(aircraft: dup).update_all(aircraft_id: good.id)
          dup.destroy!
        end
      end
    end
  end
end

end
end
