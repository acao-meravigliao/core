# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'open-uri'

module Ygg
module Acao

class FlarmnetEntry < Ygg::PublicModel
  self.table_name = 'acao.flarmnet_entries'

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft',
             optional: true

  gs_rel_map << { from: :flarmet_entry, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }

  def self.retrieve_flarmnet_db_fln
    flarmnet_db = URI.open(Rails.application.config.acao.flarmnet_ddb_url, 'r').read.lines[1..-1].map { |x|
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
    }

    flarmnet_db
  end

  def self.retrieve_flarmnet_db_ddb
    flarmnet_db = JSON.parse(URI.open(Rails.application.config.acao.flarmnet_ddb_url, 'r').read, symbolize_names: true)
    flarmnet_db[:devices]
  end

  class Cache
    attr_accessor :aircraft_by_reg
    attr_accessor :aircraft_by_flarm
    attr_accessor :aircraft_by_icao
  end

  def self.build_cache
    cache = Cache.new
    refresh_cache(cache)
    cache
  end

  def self.refresh_cache(cache)
    aircrafts = Ygg::Acao::Aircraft.all.to_a
    cache.aircraft_by_reg = Hash[aircrafts.map { |x| [x.registration, x] } ]
    cache.aircraft_by_flarm = Hash[aircrafts.map { |x| [x.flarm_identifier, x] } ]
    cache.aircraft_by_icao = Hash[aircrafts.map { |x| [x.icao_identifier, x] } ]
  end

  def self.sync!(debug: 0)
    flarmnet_db = retrieve_flarmnet_db_ddb
    flarmnet_db.sort! { |a,b| "#{a[:device_type]}-#{a[:device_id]}" <=> "#{b[:device_type]}-#{b[:device_id]}"}

    transaction do
      puts "Syncing #{flarmnet_db.count} entries"

      cache = build_cache

      Ygg::Toolkit.merge(
      l: flarmnet_db,
      r: self.all.order(device_type: :asc, device_id: :asc),
      l_cmp_r: lambda { |l,r| l[:device_type] != r.device_type ? (l[:device_type] <=> r.device_type) : (l[:device_id] <=> r.device_id) },
      l_to_r: lambda { |l|
        puts "ADD #{l}" if debug >= 2

        entry = self.new(
          device_type: l[:device_type],
          device_id: l[:device_id],
          registration: l[:registration],
          aircraft_model: l[:aircraft_model],
          cn: l[:cn],
          tracked: l[:tracked] == 'Y',
          identified: l[:identified] == 'Y',
          last_update: Time.now,
        )

        entry.associate_with_aircraft(cache: cache)
        entry.save!
      },
      r_to_l: lambda { |r|
        puts "Entry #{r.device_id} #{r.registration} removed" if debug >= 1

        r.destroy
      },
      lr_update: lambda { |l,r|
        r.update(
          registration: l[:registration],
          aircraft_model: l[:aircraft_model],
          cn: l[:cn],
          tracked: l[:tracked] == 'Y',
          identified: l[:identified] == 'Y',
        )

        r.associate_with_aircraft(cache: cache)

        if r.changes.any? || !r.last_update
          puts "UPD #{l[:device_id]} #{l[:registation]} #{r.changes}" if debug >= 2
          r.last_update = Time.now
          r.save!
        end
      })
    end

    sync = Ygg::Acao::AircraftSyncStatus.find_or_initialize_by(symbol: 'FLARMNET')
    sync.last_update = Time.now
    sync.save!
  end

  def associate_with_aircraft(cache:)
    aircraft = cache.aircraft_by_reg[registration]
    aircraft ||= cache.aircraft_by_flarm[device_id] if device_type == 'F'
    aircraft ||= cache.aircraft_by_icao[device_id] if device_type == 'I'
    self.aircraft = aircraft
  end
end

end
end
