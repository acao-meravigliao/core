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

class Ticket < Ygg::PublicModel
  self.table_name = 'acao.tickets'

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft',
             optional: true

  belongs_to :pilot1,
             class_name: 'Ygg::Acao::Member',
             optional: true

  belongs_to :pilot2,
             class_name: 'Ygg::Acao::Member',
             optional: true

  belongs_to :takeoff_airfield,
             class_name: '::Ygg::Acao::Airfield'

  belongs_to :landing_airfield,
             class_name: '::Ygg::Acao::Airfield'

  has_many :token_transactions,
           class_name: 'Ygg::Acao::TokenTransaction'

  belongs_to :volo,
             class_name: 'Ygg::Acao::MainDb::Volo',
             foreign_key: :source_id

  idxc_cached
  self.idxc_sensitive_attributes = [
    :pilot1_id,
    :pilot2_id,
    :towed_by_id,
  ]

  gs_rel_map << { from: :ticket, to: :pilot1, to_cls: 'Ygg::Acao::Member', from_key: 'pilot1_id', }
  gs_rel_map << { from: :ticket, to: :pilot2, to_cls: 'Ygg::Acao::Member', from_key: 'pilot2_id', }
  gs_rel_map << { from: :ticket, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }
  gs_rel_map << { from: :ticket, to: :takeoff_airfield, to_cls: 'Ygg::Acao::Airfield', from_key: 'takeoff_airfield_id', }
  gs_rel_map << { from: :ticket, to: :landing_airfield, to_cls: 'Ygg::Acao::Airfield', from_key: 'landing_airfield_id', }
  gs_rel_map << { from: :flight, to: :token_transaction, to_cls: 'Ygg::Acao::TokenTransaction', to_key: 'flight_id', }

  class InvalidRecord < StandardError ; end

  def sync_from_maindb(other = volo, syncer:, cache:)

    aircraft_reg = aircraft_reg_orig = other.marche_aliante.strip.upcase

    if aircraft_reg == 'I-ALTRI' ||
       aircraft_reg == 'I-ALTRO' ||
       aircraft_reg.start_with?('X-')
      aircraft_reg = nil
      aircraft = nil
    else
      self.aircraft = cache.aircrafts[aircraft_reg]
      if !self.aircraft
        self.aircraft = Ygg::Acao::Aircraft.create!(
          registration: aircraft_reg,
        )

        syncer.refresh_cache(cache)
      end
    end

    self.takeoff_airfield = cache.airfields_by_icao[other.dep.strip.upcase] || cache.airfields_by_symbol[other.dep.strip.upcase] || cache.airfields_by_icao['LILC']
    self.landing_airfield = cache.airfields_by_icao[other.arr.strip.upcase] || cache.airfields_by_symbol[other.arr.strip.upcase] || cache.airfields_by_icao['LILC']

    if other.codice_pilota_aliante.blank? || other.codice_pilota_aliante == 0
      #raise InvalidRecord, "Flight #{other.id_voli} codice_pilota_aliante is blank!"
    else
      self.pilot1 = cache.members[other.codice_pilota_aliante]
      if !self.pilot1
        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot1 code=#{other.codice_pilota_aliante}"
      end

      self.pilot1_role = 'PIC'
    end

    if other.codice_secondo_pilota_aliante == 1
      self.pilot2 = nil
      self.pilot2_role = 'PAX'
    elsif !other.codice_secondo_pilota_aliante.blank? &&
        other.codice_secondo_pilota_aliante != 0 &&
        other.codice_secondo_pilota_aliante != 1 &&
        other.codice_secondo_pilota_aliante != 9999 &&
        other.codice_secondo_pilota_aliante != 8888
      self.pilot2 = cache.members[other.codice_secondo_pilota_aliante]
      if !self.pilot2
        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot2 code=#{other.codice_secondo_pilota_aliante}"
      end

      self.pilot2_role = 'PAX'
    else
      self.pilot2 = nil
      self.pilot2_role = nil
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
      self.pilot2_role = 'FI'
      self.aircraft_class = 'GLD'
    when 2   # ALLIEVO D.C. TMG       : volo scuola su TMG (non trainato quindi) a doppio commando
      self.instruction_flight = true
      self.pilot1_role = 'DUAL'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'TMG'
    when 3   # ALLIEVO M.C.           : volo scuola trainato solista
      self.instruction_flight = true
      self.pilot1_role = 'PIC'
      self.pilot2_role = nil
      self.aircraft_class = 'GLD'
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
      self.pilot2_role = 'FI'
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
      self.maintenance_flight = true
      self.pilot1_role = 'PIC'
      self.aircraft_class = 'HELI'
      # Aggiungere Volo Officina (MCF Maintenance Check Flight)
    when 21  # ADDESTRAMENTO ALIANTE (DC) (training flight, addestramento aliante)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'GLD'
    when 22  # ADDESTRAMENTO TMG (DC) (training flight, addestramento TMG)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'TMG'
    when 23  # ADDESTRAMENTO SEP (DC) (training flight)
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FI'
      self.aircraft_class = 'SEP'
    when 24  # ESAME ALIANTE
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FE'
      self.proficiency_check = false
      self.skill_test = true
      self.aircraft_class = 'GLD'
    when 25  # ESAME TMG
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot2_role = 'FE'
      self.proficiency_check = false
      self.skill_test = true
      self.aircraft_class = 'TMG'
      self.launch_type = nil
    when 26  # ABILITAZIONE PAX
      self.instruction_flight = false
      self.pilot1_role = 'PIC'
      self.pilot1_role = 'FI'
      self.aircraft_class = 'GLD'
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

    self.tipo_volo_club = other.tipo_volo_club
#    self.acao_tipo_aereo_aliante = other.tipo_aereo_aliante
#    self.acao_durata_volo_aereo_minuti = other.durata_volo_aereo_minuti
#    self.acao_durata_volo_aliante_minuti = other.durata_volo_aliante_minuti
    self.height = other.quota != 0 ? other.quota : nil
    self.bollini = other.bollini_volo
#    self.acao_data_att = other.data_att
  end

#  def sync_from_maindb_as_sep(other = volo, cache: self.class.build_cache)
#
#    self.aircraft_reg = aircraft_reg_orig = other.marche_aereo.strip.upcase
#
#    if self.aircraft_reg == 'I-ALTRI' ||
#       self.aircraft_reg == 'I-ALTRO'
#       self.aircraft_reg.start_with?('X-')
#      self.aircraft_reg = nil
#      self.aircraft = nil
#    else
#      self.aircraft = cache.aircrafts[self.aircraft_reg]
#      if !self.aircraft
#        self.aircraft = Ygg::Acao::Aircraft.create!(
#          registration: self.aircraft_reg,
#        )
#
#        self.class.refresh_cache(cache)
#      end
#    end
#
#    self.takeoff_time = troiano_datetime_to_utc(other.ora_decollo_aereo)
#    self.landing_time = troiano_datetime_to_utc(other.ore_atterraggio_aereo)
#
##    self.towing = self.class.find_by(source_id: other.id_voli, source_expansion: 'GL')
#
#    self.takeoff_airfield = cache.airfields_by_icao[other.dep.strip.upcase] || cache.airfields_by_symbol[other.dep.strip.upcase]
#    self.landing_airfield = cache.airfields_by_icao[other.arr.strip.upcase] || cache.airfields_by_icao[other.arr.strip.upcase]
#
#    self.takeoff_location = takeoff_airfield.location if takeoff_airfield
#    self.landing_location = landing_airfield.location if landing_airfield
#
#    self.takeoff_location_raw = takeoff_airfield ? (takeoff_airfield.icao_code || takeoff_airfield.name) : other.dep.strip.upcase
#    self.landing_location_raw = landing_airfield ? (landing_airfield.icao_code || landing_airfield.name) : other.arr.strip.upcase
#
##    self.aircraft_class = aircraft && aircraft.aircraft_type && aircraft.aircraft_type.aircraft_class
#
#    if !self.aircraft_class && self.aircraft_reg == 'X-SAIL'
#      self.aircraft_class = 'GLD'
#    end
#
#    if !self.aircraft_class && aircraft_reg_orig == 'X-SLMG'
#      self.aircraft_class = 'GLD'
#    end
#
#    if !self.aircraft_class && self.aircraft_reg == 'X-ULM'
#      self.aircraft_class = 'ULM'
#    end
#
#    self.aircraft_class ||= 'SEP'
#
#    self.pilot1 = cache.members[other.codice_pilota_aereo]
#    if !self.pilot1
#      raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot1 code=#{other.codice_pilota_aereo}"
#    end
#
#    self.pilot1_name = pilot1.person.name
#    self.pilot1_role = 'PIC'
#
#    if other.codice_secondo_pilota_aereo == 1
#      self.pilot2 = nil
#      self.pilot2_name = 'PAX'
#      self.pilot2_role = 'PAX'
#    elsif !other.codice_secondo_pilota_aereo.blank? &&
#        other.codice_secondo_pilota_aereo != 0
#
#      self.pilot2 = cache.members[other.codice_secondo_pilota_aereo]
#      if !self.pilot2
#        raise InvalidRecord, "Flight #{other.id_voli} Missing referenced pilot2 code=#{other.codice_secondo_pilota_aereo}"
#      end
#
#      self.pilot2_name = pilot2.person.name
#      self.pilot2_role = 'PAX'
#    else
#      self.pilot2 = nil
#      self.pilot2_name = nil
#      self.pilot2_role = nil
#    end
#
#    if self.aircraft
#      owner = aircraft.owners.find_by(is_referent: true)
#      if owner
#        self.aircraft_owner_id = owner.member.id
#        self.aircraft_owner = owner.member.person.name
#      end
#    end
#
#    self.launch_type = nil
#
#    self.acao_tipo_volo_club = other.tipo_volo_club
#    self.acao_tipo_aereo_aliante = other.tipo_aereo_aliante
#    self.acao_durata_volo_aereo_minuti = other.durata_volo_aereo_minuti
#    self.acao_durata_volo_aliante_minuti = other.durata_volo_aliante_minuti
#    self.acao_quota = other.quota != 0 ? other.quota : nil
#
#    ma = other.marche_aliante.strip.upcase
#    if ma == '' || ma == 'NO' || ma == 'NOALI'
#      self.acao_bollini_volo = other.bollini_volo
#    else
#      self.acao_bollini_volo = nil
#    end
#
#    self.acao_data_att = other.data_att
#  end

end

end
end
