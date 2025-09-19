# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'open-uri'
require 'yaml'

module Ygg
module Acao

class Aircraft < Ygg::PublicModel
  self.table_name = 'acao.aircrafts'

  has_many :trackers,
           class_name: 'Ygg::Acao::Tracker'

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

  gs_rel_map << { from: :aircraft, to: :owner, to_cls: 'Ygg::Acao::Member', from_key: 'owner_id', }
  gs_rel_map << { from: :aircraft, to: :flight, to_cls: 'Ygg::Acao::Flight', to_key: 'aircraft_id', }
  gs_rel_map << { from: :aircraft, to: :aircraft_type, to_cls: 'Ygg::Acao::AircraftType', from_key: 'aircraft_type_id', }

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
    :owner_id,
  ]

  def self.import_flarmnet_db!
    flarmnet_db = Hash[open('http://www.flarmnet.org/files/data.fln', 'r').read.lines[1..-1].map { |x|
      s = [ x.strip ].pack('H*').force_encoding('iso-8859-15').encode('utf-8')
      [
        s[0..5].strip.upcase,
        {
         id: s[0..5].strip.upcase,
         name: s[6..26].strip,
         home: s[26..46].strip,
         type: s[46..66].strip,
         reg: s[66..75].strip,
         race_reg: s[76..78].strip.upcase,
         freq: s[79..85].strip
        }
      ]
    }]

    fenum = flarmnet_db.keys.sort!.each
    denum = self.all.where('flarm_identifier IS NOT NULL').order(flarm_identifier: :asc).each

    fcur = fenum.next rescue nil
    dcur = denum.next rescue nil

    while fcur || dcur

      if !dcur || (fcur && fcur < dcur.flarm_identifier)
        flarmnet_entry = flarmnet_db[fcur]

        puts "NEW flarmnet entry #{fcur} #{flarmnet_entry[:reg]}"

        aircraft = Ygg::Acao::Aircraft.where(flarm_identifier: nil).find_by_registration(flarmnet_entry[:reg])
        if !aircraft
          aircraft = Ygg::Acao::Aircraft.new
          aircraft.update_from_flarmnet(flarmnet_entry)

          puts "CRE #{aircraft.attributes}"

          aircraft.save!
        else
          aircraft.update_from_flarmnet(flarmnet_entry)

          if aircraft.changes.any?
            puts "UPD #{aircraft.changes}"
            aircraft.save!
          end
        end

        fcur = fenum.next rescue nil
      elsif !fcur || (dcur && fcur > dcur.flarm_identifier)
        dcur = denum.next rescue nil
      else
        dcur.update_from_flarmnet(flarmnet_db[fcur])

        if dcur.changes.any?
          puts "UPD #{dcur.changes}"
          dcur.save!
        end

        fcur = fenum.next rescue nil
        dcur = denum.next rescue nil
      end
    end
  end

  def update_from_flarmnet(entry)
    self.flarm_identifier = entry[:id]
    self.fn_owner_name = entry[:name]
    self.fn_home_airport = entry[:home]
    self.fn_type_name = entry[:type]
    self.fn_common_radio_frequency = entry[:freq]
    self.registration = entry[:reg] if !registration
    self.race_registration = entry[:race_reg] if !race_registration
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
