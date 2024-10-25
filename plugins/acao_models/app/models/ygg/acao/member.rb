#
# Copyright (C) 2017-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'vihai_password_rails'

require 'csv'

class Range
  def overlap?(other)
    ((!self.end || (other.begin  ? (self.end >= other.begin) : true)) &&
     (!self.begin || (other.end ? (self.begin <= other.end) : true)))
  end

  def merge(other)
    (self.begin && other.begin && [self.begin, other.begin].min)..
    (self.end && other.end && [self.end, other.end].max)
  end
end

class RangeArray < Array
  def flatten
    (first, *rest) = sort { |a,b| (a.begin && b.begin) ? (a.begin <=> b.begin) : (a.begin ? 1 : (b.begin ? -1 : 0)) }

    return [] if !first

    res = rest.each_with_object([first]) { |r,stack|
      stack << (stack.last.overlap?(r) ? stack.pop.merge(r) : r)
    }

    res
  end
end


module Ygg
module Acao

class Member < Ygg::PublicModel
  self.table_name = 'acao.members'

  FAAC_ACTIVE = [
    554,  # Fabio
    7002, # Daniela
    7024, # Chicca
    7017, # Matteo Negri
    1088, # Francois
    7011, # Paola Bellora
    113,  # Adriano Sandri
    7023, # Clara Ridolfi
    87,   # Nicolini
    7013, # Castelnovo
    6077, # Grinza
    1141, # Elio Cresci
    7014, # Michele Roberto Martignoni
    7008, # Alessandra Caraffini
    7010, # Luisa Clerici
    7018, # Nuri Palomino Pulizie
    500,  # Piera Bagnus
    403,  # Antonio Zanini (docente)
    942,  # Marco Gavazzi
  ]

  belongs_to :person,
          class_name: '::Ygg::Core::Person'

  has_many :memberships,
           class_name: '::Ygg::Acao::Membership'

  has_many :payments,
           class_name: '::Ygg::Acao::Payment'

  has_many :roster_entries,
           class_name: '::Ygg::Acao::RosterEntry'

  has_many :token_transactions,
           class_name: '::Ygg::Acao::TokenTransaction'

  has_many :bar_transactions,
           class_name: '::Ygg::Acao::BarTransaction'

  has_many :services,
           class_name: '::Ygg::Acao::MemberService',
           foreign_key: 'member_id'

  has_many :licenses,
           class_name: '::Ygg::Acao::License',
           foreign_key: :member_id

  has_many :medicals,
           class_name: '::Ygg::Acao::Medical',
           foreign_key: :member_id

  has_many :fai_cards,
           class_name: '::Ygg::Acao::FaiCard',
           foreign_key: :member_id

  has_many :bar_transactions,
           class_name: '::Ygg::Acao::BarTransaction',
           foreign_key: 'member_id'

  has_many :token_transactions,
           class_name: '::Ygg::Acao::TokenTransaction',
           foreign_key: 'member_id'

  has_many :aircrafts,
           class_name: '::Ygg::Acao::Aircraft',
           foreign_key: 'owner_id'

  has_many :flights,
           class_name: '::Ygg::Acao::Flight',
           foreign_key: 'pilot1_id'

  has_many :flights_as_pilot2,
           class_name: '::Ygg::Acao::Flight',
           foreign_key: 'pilot2_id'

  has_many :trailers,
           class_name: '::Ygg::Acao::Trailer',
           foreign_key: 'member_id'

  has_many :invoices,
           class_name: '::Ygg::Acao::Invoice',
           foreign_key: 'member_id'

  has_many :payments,
           class_name: '::Ygg::Acao::Payment',
           foreign_key: 'member_id'

  has_many :key_fobs,
           class_name: '::Ygg::Acao::KeyFob',
           foreign_key: 'member_id'

  has_many :person_access_remotes,
           class_name: '::Ygg::Acao::PersonAccessRemote',
           foreign_key: 'member_id'

  has_many :access_remotes,
           class_name: '::Ygg::Acao::AccessRemote',
           through: :person_access_remotes,
           source: :remote

  has_many :ml_list_members,
           class_name: '::Ygg::Ml::List::Member',
           as: :owner

  has_many :ml_lists,
           class_name: '::Ygg::Ml::List',
           source: 'list',
           through: :ml_list_members

  has_many :skysight_codes,
           class_name: 'Ygg::Acao::SkysightCode',
           foreign_key: :assigned_to_id

  # Old DB
  belongs_to :socio,
             class_name: '::Ygg::Acao::MainDb::Socio',
             primary_key: 'id_soci_dati_generale',
             foreign_key: 'ext_id',
             optional: true


  def self.gs_fetch(gs:, node:)

    rel = all

    if node.id
      rel = rel.where(id: node.id)
    elsif node.filter
      rel = rel.where(node.filter)
    end

    if node.dig
      node.dig.each do |dig|
puts "FFFFFFFFFFFFFFFFFFFFFFFFF #{dig}"

        related = nil

        if dig.from == 'member' && dig.to == 'keyfob'
          rel = rel.joins(:key_fobs).preload(:key_fobs)
        end

        if dig.from == 'member' && dig.to == 'person'
        end
      end
    end

    gs.transaction do
      rel.each do |model|
        if model
          if !gs.objs[node.id]
            gs.obj_add(model)
          end

          model.key_fobs.each do |related|
            if !gs.objs[related.id]
              gs.obj_add(related)
              gs.rel_add(a: model.id, a_as: :person, b: related.id, b_as: :keyfob)
            end
          end
        end
      end
    end

  end

#  include Comparable
#  def <=>(other)
#    id <=> other.id
#  end






  def self.lc_class_name
    'Ygg::Core::Person'
  end

  def self.alive_pilots
    where.not('sleeping')
  end

  def self.active_members(time: Time.now, grace_period: 31.days)
    members = alive_pilots.where('EXISTS (SELECT * FROM acao.memberships WHERE acao.memberships.member_id=acao.members.id ' +
                        'AND ? BETWEEN acao.memberships.valid_from AND (acao.memberships.valid_to + (? || \' seconds\')::interval))', time, grace_period)
    members
  end

  # List of members that have at least a membership for reference year 'year'.
  # This includes students which only have 6-months subscription, maybe in the past and may not be currently active
  #
  def self.members_for_year(year: Time.now.year, status: 'MEMBER')
    year = Ygg::Acao::Year.find_by!(year: year) unless year.is_a?(Ygg::Acao::Year)

    members = Ygg::Acao::Member.
                where.not('sleeping').
                where('EXISTS (SELECT * FROM acao.memberships WHERE acao.memberships.member_id=acao.member.id ' +
                        'AND acao.memberships.status=? AND acao.memberships.reference_year_id=?)', status, year.id)

    members
  end

  def compute_completed_years(from, to)
    # Number of completed years is not trivial :)

    completed_years = to.year - from.year

    if from.month > to.month ||
       (from.month == to.month && from.day > to.day)
      completed_years -= 1
    end

    completed_years
  end

  # Implementazione dei criteri che stabiliscono il numero di turni di linea da fare
  #
  def roster_entries_needed(year: Time.now.year)
    ym = Ygg::Acao::Year.find_by!(year: year)

    needed = {
      total: 2,
      high_season: 1,
    }

    # As by request from Treccilubba roster enrollment is needed for anybody, including people not paying CAV
    #
    #if !with_cav
    #  needed[:total] = 0
    #  needed[:high_season] = 0
    #  needed[:reason] = 'cav_not_paid'
    if birth_date && compute_completed_years(birth_date, ym.renew_opening_time) >= 65
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'older_than_65'
    elsif is_instructor
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'instructor'
    elsif has_disability
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'has_disability'
    elsif is_board_member
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'board_member'
    elsif is_tug_pilot
      needed[:total] = 1
      needed[:high_season] = 0
      needed[:reason] = 'tow_pilot'
    end

    ################### Temporary, remove before next renewal cycle
    # XXX

    needed = {
      total: 2,
      high_season: 0,
    }

    needed
  end

  def active?(time: Time.now)
    memberships.any? { |x| time > x.valid_from && time < x.valid_to }
  end

  def active_to(time: Time.now)
    m = memberships.select { |x| time > x.valid_from && time < x.valid_to }.max { |x| x.valid_to }
    m ? m.valid_to : nil
  end

  # Verifica che i turni di linea necessari siano stati selezionati
  #
  def roster_needed_entries_present(year: Time.now.year)
    needed = roster_entries_needed(year: year)

    roster_entries = roster_entries.joins(:roster_day).where('roster_days.date': (
      DateTime.new(year).beginning_of_year..DateTime.new(year).end_of_year
    ))

    roster_entries_high = roster_entries.where('roster_days.high_season')

    roster_entries.count >= needed[:total] && roster_entries_high.count >= needed[:high_season]
  end

  def send_initial_password!
    credential = person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first

    return if !credential

    Ygg::Ml::Msg.notify(destinations: person, template: 'SEND_INITIAL_PASSWORD', template_context: {
      first_name: person.first_name,
      password: credential.password,
     }, objects: self)
  end

  def send_welcome_message!
    return if sleeping

    credential = person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first

    return if !credential

    Ygg::Ml::Msg.notify(destinations: person, template: 'WELCOME', template_context: {
      first_name: person.first_name,
      password: credential.password,
      code: code,
     }, objects: self)
  end

  def send_happy_birthday!
    Ygg::Ml::Msg::Email.notify(destinations: person, template: 'HAPPY_BIRTHDAY', template_context: {
      first_name: person.first_name,
    })
  end


  ########### Notifications & Chores

  def self.run_chores!
    where.not('sleeping').each do |person|
      person.run_chores!
    end
  end

  def self.sync_mailing_lists!
    transaction do
      act = active_members.to_a
      act << Ygg::Acao::Member.find_by!(code: 554) # Special entry for Fabio
      act << Ygg::Acao::Member.find_by!(code: 7002) # Special entry for Daniela
      act << Ygg::Acao::Member.find_by!(code: 7024) # Special entry for Chicca
      act << Ygg::Acao::Member.find_by!(code: 7017) # Special entry for Matteo Negri

      sync_ml!(symbol: 'ACTIVE_MEMBERS', members: act.compact.uniq)

      vot = voting_members.to_a
      vot << Ygg::Acao::Member.find_by!(code: 7002)

      sync_ml!(symbol: 'VOTING_MEMBERS', members: vot.compact.uniq)

      sync_ml!(symbol: 'STUDENTS', members: active_members.where(ml_students: true))
      sync_ml!(symbol: 'INSTRUCTORS', members: active_members.where(ml_instructors: true))
      sync_ml!(symbol: 'TUG_PILOTS', members: active_members.where(ml_tug_pilots: true))
      sync_ml!(symbol: 'BOARD_MEMBERS', members: board_members)
    end

    transaction do
      sync_mailman!(list_name: 'soci', symbol: 'ACTIVE_MEMBERS')
#      sync_mailman!(list_name: 'scuola', symbol: 'STUDENTS')
      sync_mailman!(list_name: 'istruttori', symbol: 'INSTRUCTORS')
#      sync_mailman!(list_name: 'consiglio', symbol: 'BOARD_MEMBERS')
      sync_mailman!(list_name: 'trainatori', symbol: 'TUG_PILOTS')
    end
  end

  class Media
    attr_accessor :id
    attr_accessor :number
    attr_accessor :code
    attr_accessor :code_for_faac
    attr_accessor :descr
    attr_accessor :person
    attr_accessor :member_id

    def initialize(**args)
      args.each { |k,v| send("#{k}=", v) }
    end
  end

  require 'digest/md5'
  def self.derive_uuid_from_data(data)
    new_uuid = Digest::MD5.digest(data)
    new_uuid.setbyte(6, (new_uuid.getbyte(6) & 0x0f) | 0x30) # Force version to 3
    new_uuid.setbyte(8, (new_uuid.getbyte(7) & 0x3f) | 0x80) # Force variant to 1
    new_uuid = new_uuid.unpack('H*').first
    "#{new_uuid[0..7]}-#{new_uuid[8..11]}-#{new_uuid[12..15]}-#{new_uuid[16..19]}-#{new_uuid[20..31]}"
  end

  def self.derive_uuid_from_uuid(uuid)
    derive_uuid_from_data([ uuid.delete('-') ].pack('H*'))
  end

  def access_validity_ranges(from: Time.now, grace_period:)
    ranges = RangeArray.new

    if active_to
      ranges << (nil .. (active_to + grace_period).round)
    end

    if acao_socio.tessere_inizio || acao_socio.tessere_fine
      ranges << ((acao_socio.tessere_inizio && acao_socio.tessere_inizio.beginning_of_day) ..
                 (acao_socio.tessere_fine && acao_socio.tessere_fine.end_of_day))
    end

#puts "Ranges #{ranges}"

    ranges = ranges.flatten
#puts "Ranges flattened #{ranges}"

    ranges.drop_while { |x| x.end && x.end < from }

    ranges
  end

  def self.sync_with_faac!(grace_period: 1.month, debug: Rails.application.config.acao.faac_debug || 0)
    faac = FaacApi::Client.new(
      endpoint: Rails.application.config.acao.faac_endpoint,
      debug: debug - 2
    )

    faac.login(
      username: Rails.application.config.acao.faac_generic_user,
      password: Rails.application.credentials.faac_generic_user_password
    )

    r_records = faac.users_get_all.
      select { |x| x[:uniqueCode] && x[:uniqueCode].start_with?('ACAO:') }.
      sort_by { |x| x[:uniqueCode] }

    l_records = self.alive_pilots.
                 where('code <> -1').
                 where('code <> 0').
                 where('code <> 1').
                 where('code <> 4000').
                 where('code <> 4001').
                 where('code <> 7000').
                 where('code <> 9999').
                 order(id: :asc)

    users = Hash[l_records.map { |x| [ x.id, x ] }]

    merge(l: l_records, r: r_records,
    l_cmp_r: lambda { |l,r| "ACAO:#{l.id}" <=> r[:uniqueCode] },
    l_to_r: lambda { |l|
      puts "User create: #{l.code} #{l.person.first_name} #{l.person.last_name}" if debug > 0

      faac.user_create(data: {
        uuid: l.id,
        lastName: l.person.last_name,
        firstName: l.person.first_name,
        uniqueCode: "ACAO:#{l.id}",
        parentUuid: nil,
        qualification: nil,
        registrationNumber: l.code.to_s,
#          address: l.person.residence_location && l.residence_location.full_address,
        phone: l.person.contacts.where(type: 'phone').first.try(:value),
        mobile: l.person.contacts.where(type: 'mobile').first.try(:value),
#          email: l.person.contacts.where(type: 'email').first.try(:value),
      })

    },
    r_to_l: lambda { |r|
      puts "User remove: #{r[:firstName]} #{r[:lastName]}" if debug > 0

      faac.user_remove(uuid: r[:uuid])
    },
    lr_update: lambda { |l,r|
      puts "User update check: #{l.code} #{l.person.first_name} #{l.person.last_name}" if debug > 1

      intended = {
        firstName: l.person.first_name,
        lastName: l.person.last_name,
        registrationNumber: l.code.to_s,
#        address: (l.person.residence_location && l.residence_location.full_address),
        phone: l.person.contacts.where(type: 'phone').first.try(:value),
        mobile: l.contacts.where(type: 'mobile').first.try(:value),
#        email: l.contacts.where(type: 'email').first.try(:value),
      }

      diff = intended.select { |k,v| v != r[k] }

      if diff.any?
        puts "User update: #{l.code} #{l.person.first_name} #{l.person.last_name} diff=#{diff} intended=#{r} => #{intended}" if debug > 0

        faac.user_update(data: {
          uuid: l.id,
          uniqueCode: "ACAO:#{l.id}",
        }.merge(intended))
      end
    })

    # MEDIAS

    r_records = faac.medias_get_all

    # l_recods will be a union of medias from KeyFob and AccessRemote(s)
    l_records = []
    l_records += Ygg::Acao::KeyFob.all.
      select { |x| users[x.member_id] }.
      map { |x| Media.new(id: x.id, number: nil, code: x.code, person: users[x.member_id],
                          member_id: x.member_id, code_for_faac: x.code_for_faac) }

    Ygg::Acao::PersonAccessRemote.all.each do |x|
      if users[x.member_id] && x.remote.ch1_code
        l_records << Media.new(
          id: x.id,
          number: 10000 + (x.remote.symbol.to_i * 10) + 1,
          code: x.remote.ch1_code,
          member_id: x.member_id,
          person: users[x.member_id],
          code_for_faac: x.remote.ch1_code_for_faac
        )
      end

      if users[x.member_id] && x.remote.ch2_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(x.id),
          number: 10000 + (x.remote.symbol.to_i * 10) + 2,
          code: x.remote.ch2_code,
          member_id: x.member_id,
          person: users[x.member_id],
          code_for_faac: x.remote.ch2_code_for_faac
        ) if x.remote.ch2_code
      end

      if users[x.member_id] && x.remote.ch3_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(derive_uuid_from_uuid(x.id)),
          number: 10000 + (x.remote.symbol.to_i * 10) + 3,
          code: x.remote.ch3_code,
          member_id: x.member_id,
          person: users[x.member_id],
          code_for_faac: x.remote.ch3_code_for_faac
        ) if x.remote.ch3_code
      end

      if users[x.member_id] && x.remote.ch4_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(derive_uuid_from_uuid(derive_uuid_from_uuid(x.id))),
          number: 10000 + (x.remote.symbol.to_i * 10) + 4,
          code: x.remote.ch4_code,
          member_id: x.member_id,
          person: users[x.member_id],
          code_for_faac: x.remote.ch4_code_for_faac
        )
      end
    end

    # Remove media before adding to avoid identifier uniqueness issues

    merge(
    l: l_records.sort_by { |x| x.code_for_faac },
    r: r_records.sort_by { |x| x[:identifier] },
    l_cmp_r: lambda { |l,r| l.code_for_faac <=> r[:identifier] },
    l_to_r: lambda { |l| },
    r_to_l: lambda { |r|
      if users[r[:userUuid]]
        puts "Media remove (dup identifier): #{r[:uuid]} OCT=#{r[:identifier]}" if debug > 0

        faac.media_remove(uuid: r[:uuid])
      end
    },
    lr_update: lambda { |l,r| }
    )

    merge(
    l: l_records.sort_by { |x| x.id },
    r: r_records.sort_by { |x| x[:uuid] },
    l_cmp_r: lambda { |l,r| l.id <=> r[:uuid] },
    l_to_r: lambda { |l|
      puts "Media create: #{l.id} num=#{l.number} code=#{l.code} oct=#{l.code_for_faac}" if debug > 0

      ranges = access_validity_ranges(grace_period: grace_period)
      range = ranges.first

      validity_start = range && range.begin && (range.begin.to_i * 1000) || 0
      validity_end = range && range.end && (range.end.to_i * 1000) || 0
      always_valid = FAAC_ACTIVE.include?(l.person.code)

      faac.media_create(data: {
        uuid: l.id,
        identifier: l.code_for_faac,
        mediaTypeCode: 0,
#        number: l.number,
        enabled: !!range,
        validityStart: validity_start,
        validityEnd: validity_end,
        validityMode: (validity_end == 0) ? 0 : 1,
        antipassbackEnabled: false,
        countingEnabled: true,
        userUuid: l.member_id,
        profileUuidOrName: 'eb3df410-0bbd-4eb7-ac86-389c177e065b',
        lifeCycleMode: 0,
      })
    },
    r_to_l: lambda { |r|
      if users[r[:userUuid]]
        puts "Media remove: #{r[:uuid]} OCT=#{r[:identifier]}" if debug > 0

        faac.media_remove(uuid: r[:uuid])
      end
    },
    lr_update: lambda { |l,r|
      puts "Media update check #{l.id} #{l.code}" if debug > 1

      ranges = access_validity_ranges(grace_period: grace_period)
      range = ranges.first

      validity_start = range && range.begin && (range.begin.to_i * 1000) || 0
      validity_end = range && range.end && (range.end.to_i * 1000) || 0
      always_valid = FAAC_ACTIVE.include?(l.person.code)

      intended = {
        identifier: l.code_for_faac,
        mediaTypeCode: 0,
#        number: l.number,
        enabled: !!range,
        validityStart: validity_start,
        validityEnd: validity_end,
        validityMode: (validity_end == 0) ? 0 : 1,
        antipassbackEnabled: false,
        countingEnabled: true,
        userUuid: l.member_id,
        lifeCycleMode: 0,
      }

      diff = intended.select { |k,v| v != r[k] }

      if diff.any? || r[:profileUuid] != 'eb3df410-0bbd-4eb7-ac86-389c177e065b'
        puts "Media update: #{l.code} diff=#{diff} intended=#{r} => #{intended}" if debug > 0

        faac.media_update(data: {
          uuid: l.id,
          profileUuidOrName: 'eb3df410-0bbd-4eb7-ac86-389c177e065b'
        }.merge(intended))
      end
    })

  end


  def run_chores!
    transaction do
      now = Time.now
      last_run = last_notify_run || Time.new(0)

      run_roster_notification(now: now, last_run: last_run)

      if person.birth_date && (person.birth_date + 10.hours).between?(last_run, now) &&
         person.birth_date.to_date == now.to_date # Otherwise it's too late
        send_happy_birthday!
      end

#      run_license_expirations(now: now, last_run: last_run)
#      run_medical_expirations(now: now, last_run: last_run)

      self.last_notify_run = now

      save!
    end

    transaction do
      now = Time.now
      last_run = bar_last_summary || Time.new(0)

      when_during_day = now.beginning_of_day # Midnight

      if when_during_day.between?(last_run, now)
        send_bar_summary!(from: last_run, to: now.end_of_day)

        self.bar_last_summary = now
        save!
      end
    end

#    transaction do
#      now = Time.now
#      last_run = flights_last_summary || Time.new(0)
#
#      when_during_day = now.beginning_of_day # Midnight
#
#      if when_during_day.between?(last_run, now)
#        send_flight_summary!(from: last_run, to: now.end_of_day)
#
#        self.flights_last_summary = now
#        save!
#      end
#    end
  end

  def run_roster_notification(now:, last_run:)
    when_in_advance_sms = 2.days - 10.hours
    when_in_advance_mail = 7.days - 10.hours

    roster_entries.each do |entry|
      if (entry.roster_day.date.beginning_of_day - when_in_advance_mail).between?(last_run, now) &&
          entry.roster_day.date > now # Oops, too late

        Ygg::Ml::Msg::Email.notify(destinations: person, template: 'ROSTER_NEAR_NOTIFICATION', template_context: {
          first_name: person.first_name,
          date: entry.roster_day.date,
        })
      end

      if (entry.roster_day.date.beginning_of_day - when_in_advance_sms).between?(last_run, now) &&
         entry.roster_day.date > now # Oops, too late

        Ygg::Ml::Msg::Sms.notify(destinations: person, template: 'ROSTER_NEAR_NOTIFICATION_SMS', template_context: {
          first_name: person.first_name,
          date: entry.roster_day.date,
        })
      end
    end
  end

  def run_license_expirations(now:, last_run:)
    when_in_advance = 14.days - 10.hours

    licenses.each do |license|
      context = {
        first_name: person.first_name,
        license_type: license.type,
        license_identifier: license.identifier,
        license_issued_at: license.issued_at ? license.issued_at.strftime('%d-%m-%Y') : 'N/A',
        license_valid_to: license.valid_to ? license.valid_to.strftime('%d-%m-%Y') : 'N/A',
      }

      if license.valid_to
        expired = if license.valid_to.beginning_of_day.between?(last_run, now)
          'EXPIRED'
        elsif (license.valid_to.beginning_of_day - when_in_advance).between?(last_run, now)
          'EXPIRING'
        end

        if expired
          template = Ygg::Ml::Template.find_by(symbol: "LIC_#{license.type}_LICENSE_#{expired}")
          template ||= Ygg::Ml::Template.find_by!(symbol: "LIC_OTH_LICENSE_#{expired}")

          Ygg::Ml::Msg::Email.notify(destinations: person, template: template, template_context: context)
        end
      end

      if license.valid_to2
        expired = if license.valid_to2.beginning_of_day.between?(last_run, now)
          'EXPIRED'
        elsif (license.valid_to2.beginning_of_day - when_in_advance).between?(last_run, now)
          'EXPIRING'
        end

        if expired
          template = Ygg::Ml::Template.find_by(symbol: "LIC_#{license.type}_ANNUAL_#{expired}")
          template ||= Ygg::Ml::Template.find_by(symbol: "LIC_OTH_ANNUAL_#{expired}")

          if template
            Ygg::Ml::Msg::Email.notify(destinations: person, template: template, template_context: context.merge({
              license_annual_valid_to: license.valid_to2 ? license.valid_to2.strftime('%d-%m-%Y') : 'N/A',
            }))
          end
        end
      end

      license.ratings do |rating|
        if rating.valid_to
          expired = if rating.valid_to.beginning_of_day.between?(last_run, now)
            'EXPIRED'
          elsif (rating.valid_to.beginning_of_day - when_in_advance).between?(last_run, now)
            'EXPIRING'
          end

          template = Ygg::Ml::Template.find_by(symbol: "LIC_#{license.type}_#{rating.type}_#{expired}")
          template ||= Ygg::Ml::Template.find_by!(symbol: "LIC_OTH_RATING_#{expired}")

          Ygg::Ml::Msg::Email.notify(destinations: person, template: template, template_context: context.merge({
            raing_type: rating.type,
            raing_valid_to: rating.valid_to ? rating.valid_to.strftime('%d-%m-%Y') : 'N/A',
          }))
        end
      end
    end
  end

  def run_medical_expirations(now:, last_run:)
    when_in_advance = 14.days - 10.hours

    medicals.each do |medical|
      template = nil

      if medical.valid_to.beginning_of_day.between?(last_run, now)
        template = 'MEDICAL_EXPIRED'
      elsif (medical.valid_to.beginning_of_day - when_in_advance).between?(last_run, now)
        template = 'MEDICAL_EXPIRING'
      end

      if template
        Ygg::Ml::Msg::Email.notify(destinations: person, template: template, template_context: {
          first_name: person.first_name,
          medical_type: medical.type,
          medical_identifier: medical.identifier,
          medical_issued_at: medical.issued_at ? medical.issued_at.strftime('%d-%m-%Y') : 'N/A',
          medical_valid_to: medical.valid_to ? medical.valid_to.strftime('%d-%m-%Y') : 'N/A',
        })
      end
    end
  end

  def check_bar_transactions
    xacts = bar_transactions.order(recorded_at: :asc, old_id: :asc, old_cassetta_id: :asc)

    cur = xacts.first.credit || 0

    xacts.each do |xact|
      #puts "%-10s prev=%7.2f + amount=%7.2f => credit=%7.2f == cur=%7.2f" % [ xact.recorded_at.strftime('%Y-%m-%d %H:%M:%S'), xact.prev_credit || 0, xact.amount, xact.credit || 0, cur || 0 ]

      cur = cur + xact.amount

      if cur != xact.credit
        puts "Xact id=#{xact.id} credit inconsistency #{cur} != #{xact.credit}"
        cur = xact.credit if xact.credit
      end
    end

    nil
  end

  def send_bar_summary!(from:, to:)
    xacts = bar_transactions.where(recorded_at: from..to).order(recorded_at: :asc)

    return if xacts.count == 0

    # To be removed when log entries have credit,prev_credit chain
    starting_credit = bar_credit - bar_transactions.where('recorded_at > ?', from).reduce(0) { |a,x| a + x.amount }

    Ygg::Ml::Msg::Email.notify(destinations: person, template: 'BAR_SUMMARY', template_context: {
      first_name: person.first_name,
      date: xacts.first.recorded_at.strftime('%d-%m-%Y'),
      starting_credit: starting_credit,
      xacts: xacts,
    })
  end

  def send_flights_summary!(from:, to:)



                     


    xacts = bar_transactions.where(recorded_at: from..to).order(recorded_at: :asc)

    return if xacts.count == 0

    # To be removed when log entries have credit,prev_credit chain
    starting_credit = bar_credit - bar_transactions.where('recorded_at > ?', from).reduce(0) { |a,x| a + x.amount }

    Ygg::Ml::Msg::Email.notify(destinations: person, template: 'FLIGHTS_SUMMARY', template_context: {
      first_name: person.first_name,
      date: xacts.first.recorded_at.strftime('%d-%m-%Y'),
      starting_credit: starting_credit,
      xacts: xacts,
    })
  end

  ########## Mailing lists synchronization

  def self.sync_ml!(symbol:, members:, time: Time.now)
    list = Ygg::Ml::List.find_by!(symbol: symbol)
    current_members = list.members.where(owner_type: 'Ygg::Acao::Member').order(owner_id: :asc)

    merge(l: members.to_a.sort { |a,b| a.id <=> b.id }, r: current_members,
      l_cmp_r: lambda { |l,r| l.id <=> r.owner_id },
      l_to_r: lambda { |l|
        l.person.contacts.where(type: 'email').each do |contact|
          addr = Ygg::Ml::Address.find_or_create_by(addr: contact.value, addr_type: 'EMAIL')
          addr.name = l.person.name
          addr.save!

          list.members << Ygg::Ml::List::Member.new(
            address: addr,
            subscribed_on: Time.now,
            owner: l,
          )
        end
      },
      r_to_l: lambda { |r|
        r.destroy
      },
      lr_update: lambda { |l,r|
        r.address.name = l.person.name
        r.address.save! if r.address.changed?
      },
    )
  end

  def self.sync_mailman!(symbol:, list_name:, dry_run: Rails.application.config.acao.soci_ml_dry_run)

    return if Rails.application.config.ml.mailman_sync_disabled

    l_full_emails = Hash[Ygg::Ml::List.find_by!(symbol: symbol).addresses.
                     where(addr_type: 'EMAIL').order(addr: :asc).map { |x| [ x.addr.downcase, x.name ] }]

    l_emails = l_full_emails.keys.sort
    r_emails = []

    IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/list_members', list_name ]) do |io|
      data = io.read
      io.close

      if !$?.success?
        raise "Cannot list list members"
      end

      r_emails = data.split("\n").map { |x| x.strip.downcase }.sort
    end

    members_to_add = []
    members_to_remove = []

    merge(l: l_emails, r: r_emails,
      l_cmp_r: lambda { |l,r| l <=> r },
      l_to_r: lambda { |l|
        members_to_add << "#{l_full_emails[l]} <#{l}>"
      },
      r_to_l: lambda { |r|
        members_to_remove << r
      },
      lr_update: lambda { |l,r|
      }
    )

    if members_to_add.any?
      puts "MAILMAN MEMBERS TO ADD TO LIST #{list_name}:\n#{members_to_add}"

      if !dry_run
        IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/add_members',
                      '-r', '-', '--admin-notify=n', '--welcome-msg=n', list_name ], 'w') do |io|
          io.write(members_to_add.join("\n"))
          io.close
        end
      end
    end

    if members_to_remove.any?
      puts "MAILMAN MEMBERS TO REMOVE FROM LIST #{list_name}:\n#{members_to_remove}"

      if !dry_run
        IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/remove_members',
                      '--file', '-', '--nouserack', '--noadminack', list_name ], 'w') do |io|
          io.write(members_to_remove.join("\n"))
          io.close
        end
      end
    end
  end

  def self.sync_wordpress!(relation: alive_pilots, debug: Rails.application.config.acao.wp_sync_debug || 0)

    return if Rails.application.config.acao.wp_sync_disabled

    data = ''

    puts "Retrieving users list..." if debug >= 1

    IO::popen([
      '/usr/bin/ssh',
        '-i', '/var/lib/yggdra/lino',
        'lino@w1.acao.it',
        'php', '/srv/hosting/links/acao.it/wp-cli.phar',
          '--skip-plugins',
          '--path=/srv/hosting/links/acao.it/htdocs',
          'user', 'list', '--format=json' ], 'r+') do |io|
      data = JSON.parse(io.read, symbolize_names: true)
    end

    # Roles for which we are authoritative
    auth_roles = [ 'src_acao', 'socio', 'trainatore', 'allievo' ]

    updates = []

    puts "Computing changes..." if debug >= 1

    l_records = relation.includes(:contacts).includes(:credentials).sort_by { |x| x.code.to_s }
    r_records = data.select { |x| x[:roles].split(',').include?('src_acao') }.sort_by { |x| x[:user_login] }

    puts "Computing changes..." if debug >= 1

    merge(l: l_records, r: r_records,
    l_cmp_r: lambda { |l,r| l.code.to_s <=> r[:user_login] },
    l_to_r: lambda { |l|
      puts "CREATE: #{l.acao_code}" if debug >= 2

      updates << [
        l.code.to_s,
        l.person.contacts.where(type: 'email').any? ? l.person.contacts.where(type: 'email').first.value : '',
        l.person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first.password,
        l.person.first_name,
        l.person.last_name,
        l.person.name,
        wordpress_roles(l).join(','),
        l.code.to_s,
      ]
    },
    r_to_l: lambda { |r|
      puts "REMOVE: #{r[:user_login]}" if debug >= 2
    },
    lr_update: lambda { |l,r|
      puts "UPDATE CHK #{l.acao_code}" if debug >= 2

      # All current roles
      r_roles = r[:roles].split(',').sort

      # Current roles for which we are authoritative
      r_our_roles = r_roles & auth_roles

      roles = wordpress_roles(l)

      new_roles = ((r_roles - auth_roles) + roles).sort

      if debug >= 3
        puts "Current Roles = #{r_roles}"
        puts "Our current roles = #{r_our_roles}"
        puts "Our target roles = #{roles}"
        puts "Roles to update = #{new_roles}"
      end

      if new_roles != r_roles
        puts "Roles are going to be updated" if debug >= 2
      end

      updates << [
        l.code.to_s,
        l.person.contacts.where(type: 'email').any? ? l.person.contacts.where(type: 'email').first.value : '',
        l.person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first.password,
        l.person.first_name,
        l.person.last_name,
        l.person.name,
        new_roles.join(','),
        l.code.to_s,
      ]
    })

    if updates.any? && !Rails.application.config.acao.wp_sync_dry_run
      puts "Updates:\n#{updates}" if debug >= 2
      puts "Applying changes..." if debug >= 1

      csv = CSV.generate do |csv|
        csv << [ 'user_login','user_email','user_pass','first_name','last_name','display_name','roles','codice_socio' ]
        updates.each { |x| csv << x }
      end

      import_out = nil

      IO::popen([
        '/usr/bin/ssh',
          '-i', '/var/lib/yggdra/lino',
          'lino@w1.acao.it',
          'php', '/srv/hosting/links/acao.it/wp-cli.phar',
            '--skip-plugins',
            '--path=/srv/hosting/links/acao.it/htdocs',
            'user', 'import-csv', '-' ], 'r+') do |io|
        io.write(csv)
        io.close_write

        import_out = io.read
        io.close

        if !$?.success?
          raise "Cannot update wordpress users: #{data}"
        end
      end

      puts "OUT: #{import_out}" if debug >= 2
    end

    puts "Done!" if debug > 0
  end

  def self.wordpress_roles(pilot)
    roles = [ 'src_acao' ]
    roles << 'socio' if pilot.active?
    roles << 'trainatore' if pilot.is_tug_pilot
    roles << 'allievo' if pilot.is_student

    roles
  end

  ############ Old Database Synchronization

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

  def self.sync_from_maindb!(debug: 0)

    puts "Syncing" if debug >= 1

    l_records = Ygg::Acao::MainDb::Socio.order(id_soci_dati_generale: :asc).lock
    r_records = where('ext_id IS NOT NULL').order(ext_id: :asc).lock

    puts "Syncing 2" if debug >= 1

    merge(l: l_records, r: r_records,
    l_cmp_r: lambda { |l,r| l.id_soci_dati_generale <=> r.ext_id },
    l_to_r: lambda { |l|
      return if [ -1, 0, 1, 4000, 4001, 7000, 8888, 9999 ].include?(l.codice_socio_dati_generale)

      transaction do
        puts "ADDING SOCIO ID=#{l.id_soci_dati_generale} CODICE=#{l.codice_socio_dati_generale}" if debug >= 1

        person = Ygg::Core::Person.new(
        )

        member = Ygg::Acao::Member.new(
          person: person,
          ext_id: l.id_soci_dati_generale,
          roster_allowed: true,
        )

        member.sync_from_maindb(l, person: person, debug: debug)

        member.save!
        person.save!

#        member.acl_entries << Ygg::Core::Person::AclEntry.new(member: member, role: 'owner')
        person.person_roles.find_or_create_by(global_role: Ygg::Core::GlobalRole.find_by_name('simple_interface'))

        member.send_welcome_message!

        puts "ADDED #{member.awesome_inspect(plain: true)}" if debug >= 1
      end
    },
    r_to_l: lambda { |r|
      puts "REMOVED SOCIO ID=#{r.ext_id} CODICE=#{r.code} #{r.first_name} #{r.last_name}" if debug >= 1
#          r.ext_id = r.ext_id
#          r.code = nil
#          r.save!
    },
    lr_update: lambda { |l,r|

      puts "UPD CHK #{l.codice_socio_dati_generale} #{l.Nome} #{l.Cognome}" if debug >= 3

      if l.lastmod != r.lastmod || l.visita.lastmod != r.visita_lastmod
        transaction do
          p = r.person
          r.sync_from_maindb(l, person: p, debug: debug)

          if r.deep_changed? || p.deep_changed?
            puts "UPDATING #{l.id_soci_dati_generale} <=> #{r.ext_id} (#{r.person.first_name} #{r.person.last_name})" if debug >= 1
            puts r.deep_changes.awesome_inspect(plain: true) if debug >= 2

            r.save!
            p.save!
          end
        end
      end
    })
  end

  def sync_from_maindb(other = socio, person: self.person, with_logbar: true, with_logbollini: true, debug: 0)
    if other.lastmod.floor(6) != acao_lastmod
      person.first_name = (other.Nome.blank? ? '?' : other.Nome).strip.split(' ').first
      person.middle_name = (other.Nome.blank? ? '?' : other.Nome).strip.split(' ')[1..-1].join(' ')
      person.last_name = other.Cognome.strip
      person.gender = other.Sesso
      person.birth_date = other.Data_Nascita != Date.parse('1900-01-01 00:00:00 UTC') ? other.Data_Nascita : nil

      person.italian_fiscal_code = (other.Codice_Fiscale.strip != 'NO' &&
                                  other.Codice_Fiscale.strip != 'non specificato' &&
                                  !other.Codice_Fiscale.strip.blank?) ? other.Codice_Fiscale.strip : nil

      self.code = other.codice_socio_dati_generale

      self.job = (other.Professione.strip != 'non specificata' &&
                       other.Professione.strip != 'NO' &&
                       other.Professione.strip != 'NESSUNA' &&
                       !other.Professione.strip.blank?) ? other.Professione.strip : nil

      raw_address = [ other.Nato_a ].map { |x| x.strip }.
                      reject { |x| x.downcase == 'non specificato' || x.downcase == 'non specificata' || x == '?' }

      if raw_address.any? && other.Citta != 'CITTA' && other.Via != 'VIA'
        raw_address = raw_address.join(', ')
        if !person.birth_location || person.birth_location.raw_address != raw_address
          person.birth_location = Ygg::Core::Location.new_for(raw_address)
          sleep 0.3
        end
      else
        person.birth_location = nil
      end

      raw_address = [ other.Via, other.Citta, other.Provincia != 'P' ? other.Provincia : '', other.CAP, other.Stato ].map { |x| x.strip }.
                    reject { |x| x.empty? || x.downcase == 'non specificato' || x.downcase == 'non specificata' || x == '?' }

      if raw_address.any? && other.Citta != 'CITTA' && other.Via != 'VIA'
        raw_address = raw_address.join(', ')
        if !person.residence_location || person.residence_location.raw_address != raw_address
          person.residence_location = Ygg::Core::Location.new_for(raw_address)
          sleep 0.3
        end

        country = Ygg::Core::IsoCountry.find_by(a2: other.Stato.upcase == 'I' ? 'IT' : other.Stato.upcase)
        country ||= Ygg::Core::IsoCountry.find_by(italian: other.Stato.upcase)
        country ||= Ygg::Core::IsoCountry.find_by(english: other.Stato.upcase)

        person.residence_location.street_address ||= other.Via
        person.residence_location.city ||= other.Citta
        person.residence_location.country_code ||= country ? country.a2 : nil
        person.residence_location.zip ||= other.CAP
        person.residence_location.province ||= other.Provincia
        person.residence_location.save! if person.residence_location.changed? && !person.new_record?
      else
        person.residence_location = nil
      end

      self.sleeping = other.visita.socio_non_attivo
      self.bollini = other.Acconto_Voli
      self.bar_credit = other.visita.acconto_bar_euro

      if other.tag_code &&  other.tag_code.strip != '0' && other.tag_code.strip != ''
        fob = Ygg::Acao::KeyFob.find_by(code: other.tag_code.strip.upcase)
        if fob
          if fob.member_id != self.id
            puts "  keyfob #{fob.code} destroyed as it is not assigned to correct user" if debug >= 2
            fob.destroy

            puts "  keyfob #{fob.code} created" if debug >= 2
            key_fobs.build(code: other.tag_code.strip.upcase, descr: 'Aliandre', media_type: 'RFID', src: 'ALIANDRE', src_id: other.id_soci_dati_generale)
          end

          if fob.src != 'ALIANDRE' || fob.src_id != other.id_soci_dati_generale
            fob.src = 'ALIANDRE'
            fob.src_id = other.id_soci_dati_generale
            fob.descr = "From Aliandre, #{other.codice_socio_dati_generale}"

            puts "  keyfob #{fob.code} updated #{fob.changes}" if debug >= 2

            fob.save!
          end
        else
          fob = key_fobs.build(code: other.tag_code.strip.upcase, descr: 'Aliandre', media_type: 'RFID', src: 'ALIANDRE', src_id: other.id_soci_dati_generale)
          puts "  keyfob #{fob.code} created" if debug >= 2
        end

        raw_address = [ other.Via, other.Citta, other.Provincia != 'P' ? other.Provincia : '', other.CAP, other.Stato ].map { |x| x.strip }.
                      reject { |x| x.empty? || x.downcase == 'non specificato' || x.downcase == 'non specificata' || x == '?' }

        if raw_address.any? && other.Citta != 'CITTA' && other.Via != 'VIA'
          raw_address = raw_address.join(', ')
          if !residence_location || residence_location.raw_address != raw_address
            self.residence_location = Ygg::Core::Location.new_for(raw_address)
            sleep 0.3
          end

          country = Ygg::Core::IsoCountry.find_by(a2: other.Stato.upcase == 'I' ? 'IT' : other.Stato.upcase)
          country ||= Ygg::Core::IsoCountry.find_by(italian: other.Stato.upcase)
          country ||= Ygg::Core::IsoCountry.find_by(english: other.Stato.upcase)

          self.residence_location.street_address ||= other.Via
          self.residence_location.city ||= other.Citta
          self.residence_location.country_code ||= country ? country.a2 : nil
          self.residence_location.zip ||= other.CAP
          self.residence_location.province ||= other.Provincia
          self.residence_location.save! if self.residence_location.changed? && !self.new_record?
        else
          self.residence_location = nil
        end

        self.acao_bollini = other.Acconto_Voli

        if sync_tessere(debug: debug)
          puts "PILOT #{acao_code} #{first_name} #{last_name} TESSERE UPDATED" if debug >= 1
          save!
        end

        self.acao_lastmod = other.lastmod.floor(6)

        if deep_changed?
          puts "PILOT #{acao_code} #{first_name} #{last_name} CHANGED" if debug >= 1
          puts deep_changes.awesome_inspect(plain: true)

          save!
        end

        sync_contacts(other, debug: debug)
    # #   sync_memberships(other.iscrizioni)
        sync_credentials(other, debug: debug)
      end

    if self.acao_licenza_lastmod != other.licenza.lastmod.floor(6)
      puts "PILOT #{acao_code} Checking licenses"

      if sync_licenses(other.licenza, debug: debug)
        puts "PILOT #{acao_code} #{first_name} #{last_name} LICENSES UPDATED" if debug >= 1
      end

      self.acao_licenza_lastmod = other.licenza.lastmod.floor(6)
      save!
    end

    if self.acao_visita_lastmod != other.visita.lastmod.floor(6)
      puts "PILOT #{acao_code} Checking medicals"

      if sync_medicals(other.visita, debug: debug)
        puts "PILOT #{acao_code} #{first_name} #{last_name} MEDICALS UPDATED" if debug >= 1
      end

      self.acao_sleeping = other.visita.socio_non_attivo
      self.acao_bar_credit = other.visita.acconto_bar_euro

      self.acao_visita_lastmod = other.visita.lastmod.floor(6)
      save!
    end

    sync_contacts(other, person: person, debug: debug)
# #   sync_memberships(other.iscrizioni)
    sync_credentials(other, debug: debug)

    if sync_licenses(other.licenza, debug: debug)
      puts "MEMBER #{code} #{person.first_name} #{person.last_name} LICENSES UPDATED" if debug >= 1
      self.licenza_lastmod = other.licenza.lastmod
      save!
    end

    if sync_medicals(other.visita, debug: debug)
      puts "MEMBER #{code} #{person.first_name} #{person.last_name} MEDICALS UPDATED" if debug >= 1
      self.visita_lastmod = other.visita.lastmod
      save!
    end

    if with_logbar
      sync_log_bar(other.log_bar2, debug: debug)
      sync_log_bar_deposits(other.cassetta_bar_locale, debug: debug)
    end

    if with_logbollini
      sync_log_bollini(other.log_bollini)
    end
  end

  def sync_credentials(l, debug: 0)
    pw = Password.xkcd(words: 3, dict: VihaiPasswordRails.dict('it'))

    sync_credential("#{l.codice_socio_dati_generale.to_s}@cp.acao.it", pw)

    if l.Email && !l.Email.strip.empty? && l.Email.strip != 'acao@acao.it' && l.Email.strip != 'NO'
      sync_credential(l.Email.strip, pw)
    end
  end

  def sync_credential(fqda, pw)
    cred = person.credentials.find_by(fqda: fqda)
    if !cred
      person.credentials << Ygg::Core::Person::Credential::ObfuscatedPassword.new({
        fqda: fqda,
        password: pw,
      })
    end
  end

  def sync_memberships(iscrizioni)
    iscrizioni.each do |x|
      memberships.find_or_create_by(year: x.anno_iscrizione)
    end
  end

  def sync_licenses(licenza, debug: 0)
    changed = false

    if licenza.GL_SiNo && licenza.Numero_GL.strip.upcase != 'ALLIEVO' && licenza.Numero_GL.strip.upcase != 'TRAINATORE' && licenza.Numero_GL.strip != 'I-GL-?'  && licenza.Numero_GL.strip != 'I-GL-'

      identifier = (licenza.Numero_GL && licenza.Numero_GL != ''  && licenza.Numero_GL != '0') ? licenza.Numero_GL.strip : nil
      license = licenses.find_or_initialize_by(type: 'SPL', identifier: identifier)

      license.issued_at = licenza.Data_Rilascio_GL && licenza.Data_Rilascio_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Data_Rilascio_GL.floor(0) : nil

      license.valid_to = licenza.Scadenza_GL && licenza.Scadenza_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                         licenza.Scadenza_GL.floor(0) : nil

      license.valid_to2 = licenza.Annotazione_GL && licenza.Annotazione_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Annotazione_GL.floor(0) : nil

      if licenza.abilitazioneSL_SiNo
        rating = license.ratings.find_or_initialize_by(type: 'SLSS')
        rating.issued_at = (licenza.data_abil_SL && licenza.data_abil_SL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.data_abil_SL.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(type: 'SLSS').destroy_all
      end

      if licenza.Abilitazione_TMG_SiNo
        rating = license.ratings.find_or_initialize_by(type: 'TMG')
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(type: 'TMG').destroy_all
      end

      if license.changed?
        puts "LICENSE #{license.id} UPDATED"
        license.save!
        changed = true
      end
    else
      licenses.where(type: 'SPL').destroy_all
    end

    if licenza.PPL_Si_No &&
      identifier = (licenza.Numero_PPL && licenza.Numero_PPL.strip != ''  && licenza.Numero_PPL.strip != '0') ? licenza.Numero_PPL.strip : nil

      license = licenses.find_or_create_by(type: 'PPL', identifier: identifier)

      license.issued_at = licenza.Data_Rilascio_PPL && licenza.Data_Rilascio_PPL != Date.parse('1900-01-01 00:00:00 UTC') ?
                         licenza.Data_Rilascio_PPL.floor(0) : nil

      license.valid_to = (licenza.Scadenza_PPL && licenza.Scadenza_PPL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                         licenza.Scadenza_PPL.floor(0) : nil

      license.valid_to2 = (licenza.scadenza_retraining_PPL && licenza.scadenza_retraining_PPL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                         licenza.scadenza_retraining_PPL.floor(0) : nil

      if licenza.Abilitazione_TMG_SiNo
        rating = license.ratings.find_or_create_by(type: 'TMG')
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'TMG')
        rating.destroy if rating
      end

      if licenza.Abilitazione_Traino_SiNo
        rating = license.ratings.find_or_create_by(type: 'TOW')
        rating.issued_at = (licenza.Data_Abilit_Traino && licenza.Data_Abilit_Traino != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Traino.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'TOW')
        rating.destroy if rating
      end

      if licenza.Abilit_Istruttore_SiNo
        rating = license.ratings.find_or_create_by(type: 'FI')
        rating.issued_at = (licenza.Data_Abilit_Istruttore && licenza.Data_Abilit_Istruttore != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Istruttore.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'FI')
        rating.destroy if rating
      end

      if license.changed?
        puts "LICENSE #{license.id} UPDATED"
        license.save!
        changed = true
      end
    else
      licenses.where(type: 'PPL').destroy_all
    end

    if licenza.Tessera_FAI_SiNo && licenza.Numero_FAI.strip.upcase != 'FAI' && licenza.Numero_FAI.strip.upcase != '?' && licenza.Numero_GL.strip.upcase != 'D?'
      identifier = (licenza.Numero_FAI && licenza.Numero_FAI != ''  && licenza.Numero_FAI != '0') ? licenza.Numero_FAI.strip : nil
      fai_card = fai_cards.find_or_initialize_by(identifier: identifier)

      fai_card.issued_at = licenza.Data_Rilascio_FAI && licenza.Data_Rilascio_FAI != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Data_Rilascio_FAI.floor(0) : nil
      fai_card.country = 'IT'
      fai_card.valid_to = fai_card.issued_at.end_of_year.round

      if fai_card.changed?
        puts "FAI CARD #{fai_card.id} UPDATED #{fai_card.changes}"
        fai_card.save!
        changed = true
      end
    else
      fai_cards.destroy_all
    end

    changed
  end

  def sync_medicals(visita, debug: 0)
    type = "IT class #{visita.Tipo_Classe_Visita}"

    if visita && visita.Scadenza_Visita_Medica && visita.Scadenza_Visita_Medica != Date.parse('1900-01-01 00:00:00 UTC')

      medical = medicals.find_or_create_by(type: type)

      medical.issued_at = visita.Data_prima_Visita && visita.Data_prima_Visita != Date.parse('1900-01-01 00:00:00 UTC') ?
                          visita.Data_prima_Visita.floor(0) : nil

      medical.valid_to = visita.Scadenza_Visita_Medica && visita.Scadenza_Visita_Medica != Date.parse('1900-01-01 00:00:00 UTC') ?
                         visita.Scadenza_Visita_Medica.floor(0) : nil

      if medical.changed?
        medical.save!
        return true
      else
        return false
      end
    else
      medicals.where(type: type).destroy_all.any?
    end
  end

  def sync_contacts(r, person:, debug: 0)
    if r.Email && !r.Email.strip.empty? && r.Email.strip != 'acao@acao.it' && r.Email.strip != 'NO'
      person.contacts.find_or_create_by(type: 'email', value: r.Email.strip)
    end

    if r.Telefono_Casa && r.Telefono_Casa.strip != '' && r.Telefono_Casa.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: r.Telefono_Casa.strip, descr: 'Casa')
    end

    if r.Telefono_Ufficio && r.Telefono_Ufficio.strip != '' && r.Telefono_Ufficio.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: r.Telefono_Ufficio.strip, descr: 'Ufficio')
    end

    if r.Telefono_Altro && r.Telefono_Altro.strip != '' && r.Telefono_Altro.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: r.Telefono_Altro.strip, descr: 'Ufficio')
    end

    if r.Telefono_Cellulare && r.Telefono_Cellulare.strip != '' && r.Telefono_Cellulare.strip != '0'
      person.contacts.find_or_create_by(type: 'mobile', value: r.Telefono_Cellulare.strip)
    end

    if r.Fax && r.Fax.strip != '' && r.Fax.strip != '0'
      person.contacts.find_or_create_by(type: 'fax', value: r.Fax.strip)
    end

    if r.Sito_Web && r.Sito_Web.strip != '' && r.Sito_Web.strip != 'W'
      person.contacts.find_or_create_by(type: 'url', value: r.Sito_Web.strip)
    end
  end

  def troiano_datetime_to_utc(dt)
    ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end

  def self.voting_members(time: Time.now)
    active_members(time: time, grace_period: 0)
  end

  def self.students
    active_members.where(is_student: true)
  end

  def self.board_members
    active_members.where(is_board_member: true)
  end

  def self.tug_pilots
    active_members.where(is_tug_pilot: true)
  end

end

end
end
