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

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :integer, null: false, limit: 4 } ],
    [ :must_have_column, { name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "invoice_detail_id", type: :uuid, default: nil, null: true}],
    [ :must_have_column, {name: "status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "valid_from", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "valid_to", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "reference_year_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "email_allowed", type: :boolean, default: true, null: false}],
    [ :must_have_column, {name: "tug_pilot", type: :boolean, default: false, null: true}],
    [ :must_have_column, {name: "board_member", type: :boolean, default: false, null: true}],
    [ :must_have_column, {name: "instructor", type: :boolean, default: false, null: true}],
    [ :must_have_column, {name: "possible_roster_chief", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "fireman", type: :boolean, default: false, null: true}],
    [ :must_have_column, {name: "student", type: :boolean, default: false, null: true}],
    [ :must_have_index, {columns: ["uuid"], unique: true}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["person_id", "reference_year_id"], unique: true}],
    [ :must_have_index, {columns: ["reference_year_id"], unique: false}],
    [ :must_have_index, {columns: ["invoice_detail_id"], unique: false}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_years", column: "reference_year_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_invoice_details", column: "invoice_detail_id", primary_key: "id", on_delete: :nullify, on_update: nil}],
  ]

  belongs_to :person,
             class_name: '::Ygg::Core::Person'

  belongs_to :invoice_detail,
             class_name: 'Ygg::Acao::Invoice::Detail',
             optional: true

  belongs_to :reference_year,
             class_name: 'Ygg::Acao::Year'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
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

  def self.determine_base_services(person:, year:, now: Time.now)
    ass_type = 'ASS_STANDARD'
    cav_type = 'CAV_STANDARD'

    pilot = person.becomes(Ygg::Acao::Pilot)

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
      elsif person.acao_has_disability
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

    if now > year.late_renewal_deadline && !pilot.is_student # && pilot.was_member_previous_year(year: year)
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
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'DUAL_FORFAIT').id,
      removable: false,
      toggable: true,
      enabled: false,
    }

    services << {
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'SKYSIGHT').id,
      removable: false,
      toggable: true,
      enabled: false,
    }

    services << {
      service_type_id: Ygg::Acao::ServiceType.find_by!(symbol: 'METEOWIND').id,
      removable: false,
      toggable: true,
      enabled: false,
    }

    pilot.acao_aircrafts.each do |x|
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

    pilot.acao_trailers.each do |x|
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

  def self.renew(person:, payment_method:, services:, enable_email:, selected_roster_days:)
    payment = nil

    renewal_year = Ygg::Acao::Year.renewal_year
    base_services = determine_base_services(person: person, year: renewal_year)
    member = person.becomes(Ygg::Acao::Pilot)

    # Check that every non-removable service is still present, non toggable service has the previous state

    base_services.each do |bs|
      svc = services.find { |x| x[:service_type_id] == bs[:service_type_id] }
      if !bs[:removable] && !svc
        raise "Non removable service has been removed"
      end

      if !bs[:toggable] && svc && svc[:enabled] != bs[:enabled]
        raise "Non toggable service enable state has been changed"
      end
    end

    # Objects creation

    # Invoice -----------------
    invoice = Ygg::Acao::Invoice.create!(
      person: person,
      payment_method: payment_method,
    )

    member.acao_email_allowed = enable_email

    if person.acao_memberships.find_by(reference_year: renewal_year)
      raise "Membership already present"
    end

    # Services

    ass_invoice_detail = nil

    services.each do |service|
      service_type = Ygg::Acao::ServiceType.find(service[:service_type_id])

      if service[:enabled]
        invoice_detail = Ygg::Acao::Invoice::Detail.new(
          count: 1,
          service_type: service_type,
          price: service_type.price,
          descr: service_type.name,
          data: service[:extra_info],
        )
        invoice.details << invoice_detail

        if service_type.is_association
          if ass_invoice_detail
            raise "More than one association item in services"
          end

          ass_invoice_detail = invoice_detail
        end

        Ygg::Acao::MemberService.create!(
          person: person,
          service_type: service_type,
          invoice_detail: invoice_detail,
          valid_from: Time.new(renewal_year.year).beginning_of_year,
          valid_to: Time.new(renewal_year.year).end_of_year,
          service_data: service[:extra_info],
        )
      end
    end

    if !ass_invoice_detail
      raise "Missing association item in services"
    end

    # Membership
    membership = Ygg::Acao::Membership.create!(
      person: person,
      reference_year: renewal_year,
      status: 'WAITING_PAYMENT',
      invoice_detail: ass_invoice_detail,
      valid_from: Time.now,
      valid_to: Time.new(renewal_year.year).end_of_year,
      possible_roster_chief: person.acao_roster_chief,
      student: person.acao_is_student,
      tug_pilot: person.acao_is_tug_pilot,
      board_member: person.acao_is_board_member,
      instructor: person.acao_is_instructor,
      fireman: person.acao_is_fireman,
    )

    # Roster entries

    raise "Unexpected duplicate day" if selected_roster_days.uniq != selected_roster_days

    selected_roster_days.each do |day_id|
      day = Ygg::Acao::RosterDay.find(day_id)

      raise "Unexpected duplicate roster selection" if person.acao_roster_entries.any? { |x| x.roster_day == day }

      person.acao_roster_entries.create(roster_day: day)
    end

    # Done! -------------

    invoice.close!
    payment = invoice.generate_payment!(
      reason: "rinnovo associazione #{renewal_year.year}, codice pilota #{person.acao_code}",
      timeout: 10.days,
    )
    payment.save!

    Ygg::Ml::Msg.notify(destinations: person, template: 'MEMBERSHIP_RENEWED', template_context: {
      first_name: person.first_name,
      year: renewal_year.year,
      payment_expiration: payment.expires_at.strftime('%d-%m-%Y'),
    }, objects: [ invoice, payment, membership ])

    membership
  end

  def payment_completed!
    transaction do
      self.status = 'MEMBER'

      # Membership on old database

      member = person.becomes(Ygg::Acao::Pilot)
      mdb_socio = Ygg::Acao::MainDb::Socio.find_by!(codice_socio_dati_generale: member.acao_code)
      si_prev = mdb_socio.iscrizioni.find_by(anno_iscrizione: reference_year.year - 1)

      si = mdb_socio.iscrizioni.find_by(anno_iscrizione: reference_year.year)
      if !si
        si = mdb_socio.iscrizioni.create!(
          anno_iscrizione: reference_year.year,
          tipo_iscr: si_prev ? si_prev.tipo_iscr : 2,
          data_scadenza: Time.new(reference_year.year).end_of_year,
          euro_pagati: invoice_detail.invoice.total,
          note: "Fattura #{invoice_detail.invoice.identifier}",
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

        invoice_detail.invoice.details.each do |detail|
          mdb_servizio = mdb_socio.servizi.find_by(codice_servizio: detail.service_type.onda_1_code)
          if !mdb_servizio && detail.service_type.onda_1_code && detail.service_type.onda_1_code != ''
            mdb_servizio = mdb_socio.servizi.build(codice_servizio: detail.service_type.onda_1_code, anno: reference_year.year)
          end

          mdb_servizio.pagato = true
          mdb_servizio.data_pagamento = Time.now
          mdb_servizio.numero_ricevuta = invoice_detail.invoice.identifier
          mdb_servizio.save!

          if !mdb_servizio && detail.service_type.onda_2_code && detail.service_type.onda_2_code != ''
            mdb_servizio = mdb_socio.servizi.build(codice_servizio: detail.service_type.onda_2_code, anno: reference_year.year)
          end

          mdb_servizio.pagato = true
          mdb_servizio.data_pagamento = Time.now
          mdb_servizio.numero_ricevuta = invoice_detail.invoice.identifier
          mdb_servizio.save!
        end
      end

      save!

      Ygg::Ml::Msg.notify(destinations: person, template: 'MEMBERSHIP_COMPLETE', template_context: {
        first_name: person.first_name,
        year: reference_year.year,
      }, objects: self)
    end
  end

  def active?(time: Time.now)
    ym = Ygg::Acao::Year.find_by(year: year)
    return false if !ym

    time.between?(Time.new(ym.year).beginning_of_year, Time.new(ym.year).ending_of_year)
  end

end

end
end
