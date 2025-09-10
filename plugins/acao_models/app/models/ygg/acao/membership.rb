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

class Membership < Ygg::PublicModel
  self.table_name = 'acao.memberships'

  belongs_to :member,
             class_name: '::Ygg::Acao::Member'

#  belongs_to :debt_detail,
#             class_name: 'Ygg::Acao::Debt::Detail',
#             optional: true

  belongs_to :reference_year,
             class_name: 'Ygg::Acao::Year'

  gs_rel_map << { from: :membership, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :membership, to: :year, to_cls: 'Ygg::Acao::Year', from_key: 'reference_year_id', }

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  idxc_cached
  self.idxc_sensitive_attributes = [
    :member_id,
  ]

  def self.compute_completed_years(from, to)
    # Number of completed years is not trivial :)

    completed_years = to.year - from.year

    if from.month > to.month ||
       (from.month == to.month && from.day > to.day)
      completed_years -= 1
    end

    completed_years
  end

  def self.determine_base_services(member:, year:, now: Time.now)
    ass_type = 'ASS_STANDARD'
    cav_type = 'CAV_STANDARD'

    person = member.person

    if person.birth_date
      age = compute_completed_years(person.birth_date, year.renew_opening_time)

      if age < 23
        ass_type = 'ASS_23'
        cav_type = nil
      elsif age <= 26
        ass_type = 'ASS_STANDARD'
        cav_type = 'CAV_26'
      elsif age >= 75
        ass_type = 'ASS_STANDARD'
        cav_type = 'CAV_75'
      elsif member.has_disability
        # This supposes CAV_DIS is always equal or more expensive than CAV_75 a CAV_26
        ass_type = 'ASS_STANDARD'
        cav_type = 'CAV_DIS'
      else
        #if person.residence_location &&
        #   Geocoder::Calculations.distance_between(
        #     [ person.residence_location.lat, person.residence_location.lng ],
        #     [ 45.810189, 8.770963 ]) > 300000

        #  cav_amount = 700.00
        #  cav_type = 'CAV residenti oltre 300 km'
        #else

        ass_type = 'ASS_STANDARD'
        cav_type = 'CAV_STANDARD'
      end
    end

    services = []

    services << {
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: ass_type).id,
      removable: false,
      toggable: false,
      enabled: true,
    }

    if now > year.late_renewal_deadline && !member.is_student # && member.was_member_previous_year(year: year)
      services << {
        service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'ASS_LATE').id,
        removable: false,
        toggable: false,
        enabled: true,
      }
    end

    if cav_type
      services << {
        service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: cav_type).id,
        removable: false,
        toggable: true,
        enabled: true,
      }
    end

    services << {
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'CAA').id,
      removable: false,
      toggable: true,
      enabled: false,
    }

    services << {
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'CAP').id,
      removable: false,
      toggable: true,
      enabled: false,
    }

#    services << {
#      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'SKYSIGHT').id,
#      removable: false,
#      toggable: true,
#      enabled: false,
#    }

#    services << {
#      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'METEOWIND').id,
#      removable: false,
#      toggable: true,
#      enabled: false,
#    }

    member.aircrafts.each do |x|
      srvt = if x.hangar
        if x.aircraft_type.is_vintage
          'HANGAR_VNT'
        elsif x.aircraft_type.aircraft_class == 'GLD'
          if x.aircraft_type.wingspan && x.aircraft_type.wingspan <= 15
            'HANGAR_STD'
          elsif x.aircraft_type.wingspan && x.aircraft_type.wingspan <= 18
            'HANGAR_18M'
          elsif x.aircraft_type.wingspan && x.aircraft_type.wingspan <= 20
            'HANGAR_20M'
          elsif x.aircraft_type.wingspan && x.aircraft_type.wingspan <= 25
            'HANGAR_25M'
          else
            'HANGAR_BIG'
          end
        elsif x.aircraft_type.aircraft_class == 'TMG'
          'HANGAR_TMG'
        else
          if x.aircraft_type.foldable_wings
            'HANGAR_ENG_FLD'
          elsif x.aircraft_type.wingspan && x.aircraft_type.wingspan <= 10
            'HANGAR_ENG_10M'
          else
            'HANGAR_ENG_BIG'
          end
        end

        services << {
          service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: srvt).id,
          removable: true,
          toggable: false,
          enabled: true,
          extra_info: x.registration,
        }
      end
    end

    member.trailers.each do |x|
      srvt = if x.zone == 'A'
        'TRAILER_A'
      else
        'TRAILER_BC'
      end

      services << {
        service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: srvt).id,
        removable: true,
        toggable: false,
        enabled: true,
        extra_info: x.aircraft && x.aircraft.registration
      }
    end

    services
  end

  def self.renew(member:, services:, enable_email:, selected_roster_days:, force: false)
    payment = nil

    person = member.person

    renewal_year = Ygg::Acao::Year.renewal_year
    base_services = determine_base_services(member: member, year: renewal_year)

    # Check that every non-removable service is still present, non toggable service has the previous state

    if !force
      base_services.each do |bs|
        svc = services.find { |x| x[:service_type_id] == bs[:service_type_id] }
        if !bs[:removable] && !svc
          raise "Non removable service has been removed"
        end

        if !bs[:toggable] && svc && svc[:enabled] != bs[:enabled]
          raise "Non toggable service enable state has been changed"
        end
      end
    end

    membership = nil

    transaction do
      # Objects creation

      # Debt -----------------
      debt = Ygg::Acao::Debt.create!(
        member: member,
        descr: "Rinnovo associazione #{renewal_year.year}",
        expires_at: Time.now + 10.days,
        state: 'PENDING',
      )

      member.email_allowed = enable_email

      if member.memberships.find_by(reference_year: renewal_year)
        raise "Membership already present"
      end

      # Membership
      membership = Ygg::Acao::Membership.create!(
        member: member,
        reference_year: renewal_year,
        status: 'WAITING_PAYMENT',
        valid_from: Time.now,
        valid_to: (Time.local(renewal_year.year).end_of_year + 31.days).end_of_day,
        possible_roster_chief: member.roster_chief,
        student: member.is_student,
        tug_pilot: member.is_tug_pilot,
        board_member: member.is_board_member,
        instructor: member.is_instructor,
        fireman: member.is_fireman,
      )

      # Services

      services.each do |service|
        service_type = Ygg::Acao::ServiceType.find(service[:service_type_id])

        if service[:enabled]
          debt_detail = Ygg::Acao::Debt::Detail.new(
            count: 1,
            code: service_type.symbol,
            amount: service_type.price,
            vat: 0,
            descr: service_type.name,
            data: service[:extra_info],
            service_type: service_type,
            obj: service_type.is_association ? membership : nil,
          )
          debt.details << debt_detail

          Ygg::Acao::MemberService.create!(
            member: member,
            service_type: service_type,
            valid_from: Time.local(renewal_year.year).beginning_of_year,
            valid_to: (Time.local(renewal_year.year).end_of_year + 31.days).end_of_day,
            service_data: service[:extra_info],
          )
        end
      end

      # Roster entries

      raise "Unexpected duplicate day" if selected_roster_days.uniq != selected_roster_days

      selected_roster_days.each do |day_id|
        day = Ygg::Acao::RosterDay.find(day_id)

        raise "Unexpected duplicate roster selection" if member.roster_entries.any? { |x| x.roster_day == day }

        member.roster_entries.create(roster_day: day)
      end

      # Done! -------------

      Ygg::Ml::Msg.notify(destinations: person, template: 'MEMBERSHIP_RENEWED', template_context: {
        first_name: person.first_name,
        year: renewal_year.year,
        payment_expiration: debt.expires_at.strftime('%d-%m-%Y'),
      }, objects: [ debt, membership ])
    end

    membership
  end

  def payment_completed!
    transaction do
      self.status = 'MEMBER'

      # Membership on old database

      mdb_socio = Ygg::Acao::MainDb::Socio.find_by!(codice_socio_dati_generale: member.code)
      si_prev = mdb_socio.iscrizioni.find_by(anno_iscrizione: reference_year.year - 1)

      si = mdb_socio.iscrizioni.find_by(anno_iscrizione: reference_year.year)
      if !si
        si = mdb_socio.iscrizioni.create!(
          anno_iscrizione: reference_year.year,
          tipo_iscr: si_prev ? si_prev.tipo_iscr : 1,
          data_scadenza: (Time.local(reference_year.year).end_of_year + 31.days).end_of_day,
          #euro_pagati: debt_detail.debt.total,
          #note: "Fattura #{debt_detail.debt.identifier}",
          temporanea: false,
          data_iscrizione: Time.now,
        )

        mdb_socio.servizi.where(anno: reference_year.year - 1).each do |servizio|
          if servizio.tipo_servizio.ricorrente
            mdb_socio.servizi.create!(
              codice_servizio: servizio.codice_servizio,
              anno: reference_year.year,
              dati_aggiuntivi: servizio.dati_aggiuntivi,
              pagato: false,
            )
          end
        end

        # Moved into trigger replacement

#        invoice_detail.invoice.details.each do |detail|
#          mdb_servizio = mdb_socio.servizi.find_by(codice_servizio: detail.service_type.onda_1_code)
#          if !mdb_servizio && detail.service_type.onda_1_code && detail.service_type.onda_1_code != ''
#            mdb_servizio = mdb_socio.servizi.build(codice_servizio: detail.service_type.onda_1_code, anno: reference_year.year)
#          end
#
#          mdb_servizio.pagato = true
#          mdb_servizio.data_pagamento = Time.now
#          mdb_servizio.numero_ricevuta = invoice_detail.invoice.identifier
#          mdb_servizio.save!
#
#          if !mdb_servizio && detail.service_type.onda_2_code && detail.service_type.onda_2_code != ''
#            mdb_servizio = mdb_socio.servizi.build(codice_servizio: detail.service_type.onda_2_code, anno: reference_year.year)
#          end
#
#          mdb_servizio.pagato = true
#          mdb_servizio.data_pagamento = Time.now
#          mdb_servizio.numero_ricevuta = invoice_detail.invoice.identifier
#          mdb_servizio.save!
#        end
      end

      save!

      Ygg::Ml::Msg.notify(destinations: person, template: 'MEMBERSHIP_COMPLETE', template_context: {
        first_name: person.first_name,
        year: reference_year.year,
      }, objects: self)
    end
  end

  def active?(time: Time.now)
    time.between?(valid_from, valid_to)
  end

end

end
end
