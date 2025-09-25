# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'open-uri'
require 'csv'

module Ygg
module Acao

class OgnDdbEntry < Ygg::PublicModel
  self.table_name = 'acao.ogn_ddb_entries'

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft',
             optional: true

  gs_rel_map << { from: :ogn_ddb_entry, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }

  def self.retrieve_ddb_db
    db = CSV.parse(URI.open(Rails.application.config.acao.ogn_ddb_url, 'r').read, headers: :first_row, quote_char: "'")
#    db = CSV.parse(File.read('../download'), headers: :first_row, quote_char: "'")

    db.map { |x|
      {
       device_type: x['#DEVICE_TYPE'],
       device_id: x['DEVICE_ID'],
       aircraft_model: x['AIRCRAFT_MODEL'],
       aircraft_registration: x['REGISTRATION'],
       aircraft_competition_id: x['CN'],
       tracked: x['TRACKED'],
       identified: x['IDENTIFIED'],
      }
    }
  end

  def self.sync!(debug: 0)
    db = retrieve_ddb_db
    db.sort! { |a,b| "#{a[:device_type]}-#{a[:device_id]}" <=> "#{b[:device_type]}-#{b[:device_id]}"}

    transaction do
      puts "Syncing #{db.count} entries"

      Ygg::Toolkit.merge(
      l: db,
      r: self.all.order(device_type: :asc, device_id: :asc),
      l_cmp_r: lambda { |l,r| l[:device_type] != r.device_type ? (l[:device_type] <=> r.device_type) : (l[:device_id] <=> r.device_id) },
      l_to_r: lambda { |l|
        puts "ADD #{l}"

        entry = self.new(
          device_type: l[:device_type],
          device_id: l[:device_id],
          aircraft_registration: l[:aircraft_registration],
          aircraft_model: l[:aircraft_model],
          aircraft_competition_id: l[:aircraft_competition_id],
          tracked: l[:tracked] == 'Y',
          identified: l[:identified] == 'Y',
          last_update: Time.now,
        )

        entry.associate_with_aircraft
        entry.save!
      },
      r_to_l: lambda { |r|
        puts "Entry #{r.device_id} #{r.registration} removed"

        r.destroy
      },
      lr_update: lambda { |l,r|
        r.update(
          aircraft_registration: l[:aircraft_registration],
          aircraft_model: l[:aircraft_model],
          aircraft_competition_id: l[:aircraft_competition_id],
          tracked: l[:tracked] == 'Y',
          identified: l[:identified] == 'Y',
        )

        associate_with_aircraft

        if r.changes.any? || !r.last_update
          puts "UPD #{r.changes}"
          r.last_update = Time.now
          r.save!
        end
      })
    end

    sync = Ygg::Acao::AircraftSyncStatus.find_or_initialize_by(symbol: 'OGNDDB')
    sync.last_update = Time.now
    sync.save!
  end

  def associate_with_aircraft
    aircraft = Ygg::Acao::Aircraft.find_by(registration: aircraft_registration)
    aircraft ||= Ygg::Acao::Aircraft.find_by(flarm_identifier: device_id) if device_type == 'F'
    aircraft ||= Ygg::Acao::Aircraft.find_by(icao_identifier: device_id) if device_type == 'I'
    self.aircraft = aircraft
  end

end

end
end
