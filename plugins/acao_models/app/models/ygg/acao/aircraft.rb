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

  belongs_to :owner,
             class_name: 'Ygg::Acao::Member',
             optional: true

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

  gs_rel_map << { from: :aircraft, to: :owner, to_cls: 'Ygg::Acao::Member', from_key: 'owner_id', }
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
    :owner_id,
  ]

  class IncompatibleRecord < Ygg::Exception
    attr_reader :diffs

    def initialize(diffs:, **args)
      super(**args)

      @diffs = diffs
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
      :owner_id,
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
    self.where(club_id: nil, owner_id: nil, club_owner_id: nil).each do |x|
      if x.flights.empty? && x.token_transactions.empty?
        x.destroy
      end
    end
  end

  def self.inconsistences
    {
     reg_duplicated: Ygg::Acao::Aircraft.group(:registration).having('count(*) > 1').count,
     
    }
  end

  def self.sync_from_maindb!(debug: 0)
    dups = Ygg::Acao::MainDb::Mezzo.select('numero_flarm,count(*)').where("numero_flarm <> 'id'").where("numero_flarm <> ''").
                                    group(:numero_flarm).having('count(*) > 1')
    if dups.to_a.any?
      puts "Duplicate aircraft with same flarm identifier!"
      dups.each { |x| puts x.numero_flarm }
      fail
    end

    Ygg::Acao::MainDb::Mezzo.where("numero_flarm <> 'id'").where("numero_flarm <> ''").each do |mezzo|

      flarm_identifier = mezzo.numero_flarm.strip.upcase
      registration = mezzo.Marche.strip.upcase

      data = {
        mdb_id: mezzo.id_mezzi,
        registration: registration,
      }

      race_registration = mezzo.sigla_gara.strip.upcase
      data[:race_registration] = race_registration if race_registration != 'S'

      p = Ygg::Acao::Aircraft.find_by(flarm_identifier: flarm_identifier) ||
          Ygg::Acao::Aircraft.find_by(registration: registration)
      if !p
        data.merge!({ flarm_identifier: flarm_identifier })
        puts "CRE #{data}" if debug >= 1
        Ygg::Acao::Aircraft.create!(data)
      else
        p.assign_attributes(data)

        if p.changes.any?
          puts "UPD #{p.changes}" if debug >= 1
          p.save!
        end
      end

    end
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
