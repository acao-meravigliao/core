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

class Flight < Ygg::PublicModel
  self.table_name = 'acao.flights'

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft',
             optional: true

  belongs_to :pilot1,
             class_name: 'Ygg::Acao::Member',
             optional: true

  belongs_to :pilot2,
             class_name: 'Ygg::Acao::Member',
             optional: true

  belongs_to :takeoff_location,
             class_name: '::Ygg::Core::Location',
             optional: true

  belongs_to :landing_location,
             class_name: '::Ygg::Core::Location',
             optional: true

  belongs_to :takeoff_airfield,
             class_name: '::Ygg::Acao::Airfield',
             optional: true

  belongs_to :landing_airfield,
             class_name: '::Ygg::Acao::Airfield',
             optional: true

  belongs_to :tow_release_location,
             class_name: '::Ygg::Core::Location',
             optional: true

  belongs_to :towed_by,
             class_name: 'Ygg::Acao::Flight',
             optional: true

  has_one :towing,
           class_name: 'Ygg::Acao::Flight',
           foreign_key: :towed_by_id

  has_many :token_transactions,
           class_name: 'Ygg::Acao::TokenTransaction'

  belongs_to :volo,
             class_name: 'Ygg::Acao::MainDb::Volo',
             foreign_key: :source_id,
             optional: true

  idxc_cached
  self.idxc_sensitive_attributes = [
    :pilot1_id,
    :pilot2_id,
    :towed_by_id,
  ]

  gs_rel_map << { from: :flight, to: :pilot1, to_cls: 'Ygg::Acao::Member', from_key: 'pilot1_id', }
  gs_rel_map << { from: :flight, to: :pilot2, to_cls: 'Ygg::Acao::Member', from_key: 'pilot2_id', }
  gs_rel_map << { from: :flight, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }
  gs_rel_map << { from: :flight, to: :takeoff_airfield, to_cls: 'Ygg::Acao::Airfield', from_key: 'takeoff_airfield_id', }
  gs_rel_map << { from: :flight, to: :landing_airfield, to_cls: 'Ygg::Acao::Airfield', from_key: 'landing_airfield_id', }
  gs_rel_map << { from: :flight, to: :takeoff_location, to_cls: 'Ygg::Core::Location', from_key: 'takeoff_location_id', }
  gs_rel_map << { from: :flight, to: :landing_location, to_cls: 'Ygg::Core::Location', from_key: 'landing_location_id', }
  gs_rel_map << { from: :towing, to: :towed_by, to_cls: 'Ygg::Acao::Flight', from_key: 'towed_by_id', }
  gs_rel_map << { from: :towed_by, to: :towing, to_cls: 'Ygg::Acao::Flight', to_key: 'towed_by_id', }
  gs_rel_map << { from: :flight, to: :token_transaction, to_cls: 'Ygg::Acao::TokenTransaction', to_key: 'flight_id', }

  class InvalidRecord < StandardError ; end

  def self.sync_from_maindb!(from_time: nil, start: nil, stop: nil, debug: 0)

    if from_time
      ff = Ygg::Acao::Flight.order(takeoff_time: :asc).where('takeoff_time > ?', from_time).first
      ff = Ygg::Acao::Flight.last if !ff
      return if !ff
      start = ff.source_id

      puts "Starting from flight #{start}" if debug >= 1
    end

    # Do towplane flight (first, so that we can look it up for towed_by later)

    cache = build_cache

    # ============================== TOW ==================================
    l_relation = Ygg::Acao::MainDb::Volo.all.
                   where('upper(trim(marche_aereo)) <> \'\'').
                   where('upper(trim(marche_aereo)) <> \'NO\'').
                   where('upper(trim(marche_aereo)) <> \'AUTO\'').
                   where('upper(trim(marche_aereo)) <> \'X-WINCH\'').
                   where('CAST (ora_decollo_aereo AS time) <> \'00:00:00\'').
                   where('CAST (ore_atterraggio_aereo AS time) <> \'00:00:00\'').
                   where('CAST (ora_atterraggio_aliante AS time) <> \'00:00:00\'').
                   order(id_voli: :asc)
    l_relation = l_relation.where('id_voli >= ?', start) if start
    l_relation = l_relation.where('id_voli <= ?', stop) if stop

    r_relation = Ygg::Acao::Flight.
                   where(source: 'OLDDB').
                   where('source_id IS NOT NULL').
                   where(source_expansion: 'TOW').
                   order(source_id: :asc)
    r_relation = r_relation.where('source_id >= ?', start) if start
    r_relation = r_relation.where('source_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_voli <=> r.source_id },
    l_to_r: lambda { |l|
      puts "TOW CHK ADD #{l.id_voli}" if debug >= 3

      begin
        puts "ADDING TOW FLIGHT ID=#{l.id_voli}" if debug >= 1

        transaction do
          tow_flight = Ygg::Acao::Flight.new(
            source: 'OLDDB',
            source_id: l.id_voli,
            source_expansion: 'TOW',
          )

          tow_flight.sync_from_maindb_as_sep(l, cache: cache)
          tow_flight.save!
        end
      rescue InvalidRecord => e
        puts "OOOOOOOOOOOOOOOOHHHHHHHHH In record #{l.id_voli} (TOW): #{e.to_s}"
      end
    },
    r_to_l: lambda { |r|
      puts "TOW DEL #{r.source_id}" if debug >= 1
      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "TOW CMP #{l.id_voli}" if debug >= 3

      transaction do
        r.sync_from_maindb_as_sep(l, cache: cache)

        if r.deep_changed?
          puts "UPDATING TOW FLIGHT ID=#{l.id_voli}" if debug >= 1
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      end
    })

    # ============================== GL ==================================

    l_relation = Ygg::Acao::MainDb::Volo.all.
                   where('upper(trim(marche_aliante)) <> \'\'').
                   where('upper(trim(marche_aliante)) <> \'NO\'').
                   where('upper(trim(marche_aliante)) <> \'NOALI\'').
                   where('upper(trim(marche_aliante)) <> \'ACAO\'').
                   where('upper(trim(marche_aliante)) <> \'DG1000\'').
                   order(id_voli: :asc)
    l_relation = l_relation.where('id_voli >= ?', start) if start
    l_relation = l_relation.where('id_voli <= ?', stop) if stop

    r_relation = Ygg::Acao::Flight.
                   where(source: 'OLDDB').
                   where('source_id IS NOT NULL').
                   where(source_expansion: 'GL').
                   order(source_id: :asc)
    r_relation = r_relation.where('source_id >= ?', start) if start
    r_relation = r_relation.where('source_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_voli <=> r.source_id },
    l_to_r: lambda { |l|
      puts "GL CHK ADD #{l.id_voli}" if debug >= 3

      begin
        puts "GL ADD FLIGHT ID=#{l.id_voli}" if debug >= 1

        transaction do
          gl_flight = Ygg::Acao::Flight.new(
            source: 'OLDDB',
            source_id: l.id_voli,
            source_expansion: 'GL',
          )

          gl_flight.sync_from_maindb_as_gl(l, cache: cache)
          gl_flight.save!
        end
      rescue InvalidRecord => e
        puts "OOOOOOOOOOOOOOOOHHHHHHHHH In record #{l.id_voli} (GL): #{e.to_s}"
      end
    },
    r_to_l: lambda { |r|
      puts "GL DEL #{r.source_id}" if debug >= 1
      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "GL CMP #{l.id_voli}" if debug >= 3

      transaction do
        r.sync_from_maindb_as_gl(l, cache: cache)

        if r.deep_changed?
          puts "GL UPD FLIGHT #{l.id_voli}" if debug >= 1
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      end
    })

    # ============================== TICKETS ==================================

    l_relation = Ygg::Acao::MainDb::Volo.all.
                   where('upper(trim(marche_aereo)) <> \'X-WINCH\'').
                   where('CAST (ora_decollo_aereo AS time) = \'00:00:00\'').
                   where('CAST (ore_atterraggio_aereo AS time) = \'00:00:00\'').
                   where('CAST (ora_atterraggio_aliante AS time) = \'00:00:00\'').
                   order(id_voli: :asc)
    l_relation = l_relation.where('id_voli >= ?', start) if start
    l_relation = l_relation.where('id_voli <= ?', stop) if stop

    r_relation = Ygg::Acao::Ticket.
                   where(source: 'OLDDB').
                   where('source_id IS NOT NULL').
                   order(source_id: :asc)
    r_relation = r_relation.where('source_id >= ?', start) if start
    r_relation = r_relation.where('source_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.id_voli <=> r.source_id },
    l_to_r: lambda { |l|
      puts "TIK CHK ADD #{l.id_voli}" if debug >= 3

      begin
        puts "ADDING TICKET ID=#{l.id_voli}" if debug >= 1

        transaction do
          ticket = Ygg::Acao::Ticket.new(
            source: 'OLDDB',
            source_id: l.id_voli,
          )

          ticket.sync_from_maindb(l, syncer: self, cache: cache)
          ticket.save!
        end
      rescue InvalidRecord => e
        puts "OOOOOOOOOOOOOOOOHHHHHHHHH In record #{l.id_voli} (TOW): #{e.to_s}"
      end
    },
    r_to_l: lambda { |r|
      puts "TICKET DEL #{r.source_id}" if debug >= 1
      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "TICKET CMP #{l.id_voli}" if debug >= 3

      transaction do
        r.sync_from_maindb(l, syncer: self, cache: cache)

        if r.deep_changed?
          puts "UPDATING TICKET ID=#{l.id_voli}" if debug >= 1
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      end
    })

  end

  class Cache
    attr_accessor :airfields_by_icao
    attr_accessor :airfields_by_symbol
    attr_accessor :members
    attr_accessor :aircrafts
  end

  def self.build_cache
    cache = Cache.new
    refresh_cache(cache)
    cache
  end

  def self.refresh_cache(cache)
    af = Ygg::Acao::Airfield.all.to_a
    cache.airfields_by_icao = Hash[af.map { |x| [x.icao_code, x] }]
    cache.airfields_by_symbol = Hash[af.map { |x| [x.symbol, x] }]
    cache.members = Hash[ Ygg::Acao::Member.all.map { |x| [x.code, x] } ]
    cache.aircrafts = Hash[ Ygg::Acao::Aircraft.all.map { |x| [x.registration, x] } ]
  end

  def sync_from_maindb_as_gl(other = volo, cache: self.class.build_cache)

    self.aircraft_reg = aircraft_reg_orig = other.marche_aliante.strip.upcase

    if self.aircraft_reg == 'I-ALTRI' ||
       self.aircraft_reg == 'I-ALTRO' ||
       self.aircraft_reg.start_with?('X-')
      self.aircraft_reg = nil
      self.aircraft = nil
    else
      self.aircraft = cache.aircrafts[self.aircraft_reg]
      if !self.aircraft
        self.aircraft = Ygg::Acao::Aircraft.create!(
          registration: self.aircraft_reg,
        )

        self.class.refresh_cache(cache)
      end
    end

    self.takeoff_time = troiano_datetime_to_utc(other.ora_decollo_aereo)
    self.landing_time = troiano_datetime_to_utc(other.ora_atterraggio_aliante)

    self.towed_by = self.class.find_by(source_id: other.id_voli, source_expansion: 'TOW')

    self.takeoff_airfield = cache.airfields_by_icao[other.dep.strip.upcase] || cache.airfields_by_symbol[other.dep.strip.upcase]
    self.landing_airfield = cache.airfields_by_icao[other.arr.strip.upcase] || cache.airfields_by_icao[other.arr.strip.upcase]

    self.takeoff_location = takeoff_airfield.location if takeoff_airfield
    self.landing_location = landing_airfield.location if landing_airfield

    self.takeoff_location_raw = takeoff_airfield ? takeoff_airfield.icao_code || takeoff_airfield.name : other.dep.strip.upcase
    self.landing_location_raw = landing_airfield ? landing_airfield.icao_code || landing_airfield.name : other.arr.strip.upcase

    if other.codice_pilota_aliante.blank? || other.codice_pilota_aliante == 0
      #raise InvalidRecord, "Flight #{other.id_voli} codice_pilota_aliante is blank!"
    else
      self.pilot1 = cache.members[other.codice_pilota_aliante]
      if !self.pilot1
        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot1 code=#{other.codice_pilota_aliante}"
      end

      self.pilot1_name = pilot1.person.name
      self.pilot1_role = 'PIC'
    end

    if other.codice_secondo_pilota_aliante == 1
      self.pilot2 = nil
      self.pilot2_role = 'PAX'
      self.pilot2_name = 'PAX'
    elsif !other.codice_secondo_pilota_aliante.blank? &&
        other.codice_secondo_pilota_aliante != 0 &&
        other.codice_secondo_pilota_aliante != 1 &&
        other.codice_secondo_pilota_aliante != 9999 &&
        other.codice_secondo_pilota_aliante != 8888
      self.pilot2 = cache.members[other.codice_secondo_pilota_aliante]
      if !self.pilot2
        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot2 code=#{other.codice_secondo_pilota_aliante}"
      end

      self.pilot2_name = pilot2.person.name
      self.pilot2_role = 'PAX'
    else
      self.pilot2 = nil
      self.pilot2_name = nil
      self.pilot2_role = nil
    end

    if self.aircraft
      owner = aircraft.owners.find_by(is_referent: true)
      if owner
        self.aircraft_owner_id = owner.member.id
        self.aircraft_owner = owner.member.person.name
      end
    end

    if other.marche_aereo.strip == 'AUTO'
      self.launch_type = 'SL'
    elsif other.marche_aereo.strip == 'X-WINCH'
      self.launch_type = 'WINCH'
    elsif aircraft && aircraft.aircraft_type && aircraft.aircraft_type.aircraft_class == 'TMG'
      self.launch_type = nil
    else
      self.launch_type = 'TOW'
    end

    case other.tipo_volo_club
    when 0   # ERRORE
      self.instruction_flight = false
      self.pilot1_role = nil
      self.pilot2_role = nil
    when 1   # ALLIEVO D.C.           : volo scuola trainato doppio commando
      self.instruction_flight = true
      self.pilot1_role = 'DUAL'
      self.pilot2_role = 'FI_PIC'
      self.aircraft_class = 'GLD'
      self.purpose = 'INSTRUCTION'
    when 2   # ALLIEVO D.C. TMG       : volo scuola su TMG (non trainato quindi) a doppio commando
      self.instruction_flight = true
      self.pilot1_role = 'DUAL'
      self.pilot2_role = 'FI_PIC'
      self.aircraft_class = 'TMG'
      self.purpose = 'INSTRUCTION'
    when 3   # ALLIEVO M.C.           : volo scuola trainato solista
      self.instruction_flight = true
      self.pilot1_role = 'PIC'
      self.pilot2_role = nil
      self.aircraft_class = 'GLD'
      self.purpose = 'INSTRUCTION'
    when 4   # ALIANTE CLUB S.S.      : volo non scuola trainato su monoposto del ACAO
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = nil
      self.aircraft_class = 'GLD'
    when 5   # ALIANTE CLUB D.S.      : volo non scuola trainato su biposto del ACAO
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 6   # VOLO TMG CLUB          : volo non scuola su TMG del ACAO
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'TMG'
      self.launch_type = nil
    when 7   # ALIANTE PRIVATO S.S    : volo non scuola trainato su monoposto privato
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 8   # ALIANTE PRIVATO D.S.   : volo non scuola trainato su biposto privato
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 9   # TMG PRIVATO            : volo non scuola su TMG privato
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'TMG'
      self.launch_type = nil
    when 10  # ALIANTE DEC. AUT. PRIV.: volo non scuola non trainato su SLMG privato
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 11  # LANCIO VERRICELLO      : forse per i voli eseguiti fuori sede ?
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
      self.launch_type = 'WINCH'
    when 12  # VOLO SEP CLUB          : volo non scuola di un monomotore (traino) del ACAO senza aliante
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'SEP'
    when 13  # VOLO SEP PRIVATO       : volo non scuola di un monomotore privato senza aliante
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'SEP'
    when 14  # VOLO PROMO             : volo propaganda (a pagamento)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 15  # ALIANTE SLMG CLUB
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'GLD'
    when 16  # VDS  ALLIEVO D.C.
      self.instruction_flight = true
      self.pilot1_role = 'DUAL'
      self.pilot2_role = 'FI_PIC'
      self.aircraft_class = 'ULM'
    when 17  # VDS ALLIEVO M.C.
      self.instruction_flight = true
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'ULM'
    when 18  # VDS PRIVATO
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'ULM'
    when 19  # ELICOTTERO PRIVATO
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'HELI'
    when 20  # VOLO PROVA (officina)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'HELI'
      self.purpose = 'MAINT'
      # Aggiungere Volo Officina (MCF Maintenance Check Flight)
    when 21  # ADDESTRAMENTO ALIANTE (DC) (training flight, addestramento aliante)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'GLD'
      self.purpose = 'TRAINING'
    when 22  # ADDESTRAMENTO TMG (DC) (training flight, addestramento TMG)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'TMG'
      self.purpose = 'TRAINING'
    when 23  # ADDESTRAMENTO SEP (DC) (training flight)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'SEP'
      self.purpose = 'TRAINING'
    when 24  # ESAME ALIANTE
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FE'
      self.aircraft_class = 'GLD'
      self.purpose = 'SKILL_TEST'
    when 25  # ESAME TMG
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FE'
      self.aircraft_class = 'TMG'
      self.launch_type = nil
      self.purpose = 'SKILL_TEST'
    when 26  # ABILITAZIONE PAX
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot1_role = 'FI'
      self.aircraft_class = 'GLD'
      self.purpose = 'PAX_ENDORSMENT'
    end

    if !self.aircraft_class && aircraft_reg_orig == 'X-SAIL'
      self.aircraft_class = 'GLD'
    end

    if !self.aircraft_class && aircraft_reg_orig == 'X-SLMG'
      self.aircraft_class = 'GLD'
    end

    if !self.aircraft_class && aircraft_reg_orig == 'X-ULM'
      self.aircraft_class = 'ULM'
    end

    self.aircraft_class ||= aircraft && aircraft.aircraft_type && aircraft.aircraft_type.aircraft_class

    self.acao_tipo_volo_club = other.tipo_volo_club
    self.acao_tipo_aereo_aliante = other.tipo_aereo_aliante
    self.acao_durata_volo_aereo_minuti = other.durata_volo_aereo_minuti
    self.acao_durata_volo_aliante_minuti = other.durata_volo_aliante_minuti
    self.acao_quota = other.quota != 0 ? other.quota : nil
    self.acao_bollini_volo = other.bollini_volo
    self.acao_data_att = other.data_att
  end

  def sync_from_maindb_as_sep(other = volo, cache: self.class.build_cache)

    self.aircraft_reg = aircraft_reg_orig = other.marche_aereo.strip.upcase

    if self.aircraft_reg == 'I-ALTRI' ||
       self.aircraft_reg == 'I-ALTRO'
       self.aircraft_reg.start_with?('X-')
      self.aircraft_reg = nil
      self.aircraft = nil
    else
      self.aircraft = cache.aircrafts[self.aircraft_reg]
      if !self.aircraft
        self.aircraft = Ygg::Acao::Aircraft.create!(
          registration: self.aircraft_reg,
        )

        self.class.refresh_cache(cache)
      end
    end

    self.takeoff_time = troiano_datetime_to_utc(other.ora_decollo_aereo)
    self.landing_time = troiano_datetime_to_utc(other.ore_atterraggio_aereo)

#    self.towing = self.class.find_by(source_id: other.id_voli, source_expansion: 'GL')

    self.takeoff_airfield = cache.airfields_by_icao[other.dep.strip.upcase] || cache.airfields_by_symbol[other.dep.strip.upcase]
    self.landing_airfield = cache.airfields_by_icao[other.arr.strip.upcase] || cache.airfields_by_icao[other.arr.strip.upcase]

    self.takeoff_location = takeoff_airfield.location if takeoff_airfield
    self.landing_location = landing_airfield.location if landing_airfield

    self.takeoff_location_raw = takeoff_airfield ? (takeoff_airfield.icao_code || takeoff_airfield.name) : other.dep.strip.upcase
    self.landing_location_raw = landing_airfield ? (landing_airfield.icao_code || landing_airfield.name) : other.arr.strip.upcase

#    self.aircraft_class = aircraft && aircraft.aircraft_type && aircraft.aircraft_type.aircraft_class

    if !self.aircraft_class && self.aircraft_reg == 'X-SAIL'
      self.aircraft_class = 'GLD'
    end

    if !self.aircraft_class && aircraft_reg_orig == 'X-SLMG'
      self.aircraft_class = 'GLD'
    end

    if !self.aircraft_class && self.aircraft_reg == 'X-ULM'
      self.aircraft_class = 'ULM'
    end

    self.aircraft_class ||= 'SEP'

    self.pilot1 = cache.members[other.codice_pilota_aereo]
    if !self.pilot1
      raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot1 code=#{other.codice_pilota_aereo}"
    end

    self.pilot1_name = pilot1.person.name
    self.pilot1_role = 'PIC'

    if other.codice_secondo_pilota_aereo == 1
      self.pilot2 = nil
      self.pilot2_name = 'PAX'
      self.pilot2_role = 'PAX'
    elsif !other.codice_secondo_pilota_aereo.blank? &&
        other.codice_secondo_pilota_aereo != 0

      self.pilot2 = cache.members[other.codice_secondo_pilota_aereo]
      if !self.pilot2
        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot2 code=#{other.codice_secondo_pilota_aereo}"
      end

      self.pilot2_name = pilot2.person.name
      self.pilot2_role = 'PAX'
    else
      self.pilot2 = nil
      self.pilot2_name = nil
      self.pilot2_role = nil
    end

    if self.aircraft
      owner = aircraft.owners.find_by(is_referent: true)
      if owner
        self.aircraft_owner_id = owner.member.id
        self.aircraft_owner = owner.member.person.name
      end
    end

    self.launch_type = nil

    self.acao_tipo_volo_club = other.tipo_volo_club
    self.acao_tipo_aereo_aliante = other.tipo_aereo_aliante
    self.acao_durata_volo_aereo_minuti = other.durata_volo_aereo_minuti
    self.acao_durata_volo_aliante_minuti = other.durata_volo_aliante_minuti
    self.acao_quota = other.quota != 0 ? other.quota : nil

    ma = other.marche_aliante.strip.upcase
    if ma == '' || ma == 'NO' || ma == 'NOALI'
      self.acao_bollini_volo = other.bollini_volo
    else
      self.acao_bollini_volo = nil
    end

    self.acao_data_att = other.data_att
  end

  def troiano_datetime_to_utc(dt)
    dt.to_a[0..2] == [0,0,0] ? nil : ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end

  def role_for(member)
    pilot1_id == member.id ? pilot1_role : (pilot2_id == member.id ? pilot2_role : nil)
  end

end

end
end
