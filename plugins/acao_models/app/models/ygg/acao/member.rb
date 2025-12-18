# frozen_string_literal: true
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

  belongs_to :person,
          class_name: '::Ygg::Core::Person'

  has_many :roles,
          class_name: '::Ygg::Acao::Member::Role'

  has_many :memberships,
           class_name: '::Ygg::Acao::Membership'

  has_many :debts,
           class_name: '::Ygg::Acao::Debt'

  has_many :payments,
           class_name: '::Ygg::Acao::Payment'

  has_many :aircraft_owners,
           class_name: '::Ygg::Acao::Aircraft::Owner'

  has_many :aircrafts,
           class_name: '::Ygg::Acao::Aircraft',
           through: :aircraft_owners

  has_many :onda_invoice_exports,
           class_name: 'Ygg::Acao::OndaInvoiceExport'

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

  has_many :access_remotes,
           class_name: '::Ygg::Acao::AccessRemote',
           foreign_key: 'member_id'

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

  gs_rel_map << { from: :member, to: :role, to_cls: 'Ygg::Acao::Member::Role', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :service, to_cls: 'Ygg::Acao::MemberService', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :medical, to_cls: 'Ygg::Acao::Medical', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :license, to_cls: 'Ygg::Acao::License', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :fai_card, to_cls: 'Ygg::Acao::FaiCard', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :membership, to_cls: 'Ygg::Acao::Membership', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :aircraft_owner, to_cls: 'Ygg::Acao::Aircraft::Owner', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :keyfob, to_cls: 'Ygg::Acao::KeyFob', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :roster_entry, to_cls: 'Ygg::Acao::RosterEntry', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :bar_transaction, to_cls: 'Ygg::Acao::BarTransaction', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :token_transaction, to_cls: 'Ygg::Acao::TokenTransaction', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :debt, to_cls: 'Ygg::Acao::Debt', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :payment, to_cls: 'Ygg::Acao::Payment', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :invoice, to_cls: 'Ygg::Acao::Invoice', to_key: 'member_id', }
  gs_rel_map << { from: :owner, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', to_key: 'owner_id', }
  gs_rel_map << { from: :acao_member, to: :person, to_cls: 'Ygg::Core::Person', from_key: 'person_id', }
  gs_rel_map << { from: :pilot1, to: :flight, to_cls: 'Ygg::Acao::Flight', to_key: 'pilot1_id', }
  gs_rel_map << { from: :pilot2, to: :flight, to_cls: 'Ygg::Acao::Flight', to_key: 'pilot2_id', }
  gs_rel_map << { from: :member, to: :key_fob, to_cls: 'Ygg::Acao::KeyFob', to_key: 'member_id', }
  gs_rel_map << { from: :member, to: :access_remote, to_cls: 'Ygg::Acao::AccessRemote', to_key: 'member_id', }

  def self.alive_pilots
    where.not('sleeping')
  end

  def self.active_members(time: Time.now)
    members = alive_pilots.where('EXISTS (SELECT * FROM acao.memberships WHERE acao.memberships.member_id=acao.members.id ' +
                        'AND ? BETWEEN acao.memberships.valid_from AND (acao.memberships.valid_to))', time)
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

  # Verifica che i turni di linea necessari siano stati selezionati
  #
  def roster_needed_entries_present(time: Time.now)
    needed = roster_entries_needed(time: time)

    entries = roster_entries.joins(:roster_day).where('roster_days.date': (
      time.beginning_of_year..time.end_of_year
    ))

    entries_high = entries.where('roster_days.high_season')

    entries.count >= needed[:total] && entries_high.count >= needed[:high_season]
  end

  # Implementazione dei criteri che stabiliscono il numero di turni di linea da fare
  #
  def roster_entries_needed(time: Time.now)
    ym = Ygg::Acao::Year.find_by!(year: time.year)

    role_models = roles_at(time: time)
    roles = role_models.map(&:symbol)

    needed = {
      total: 0,
      high_season: 0,
    }

    if roles.include?('SPL_PILOT') ||
       roles.include?('SPL_STUDENT')

      if person.birth_date && compute_completed_years(person.birth_date, ym.age_reference_date) >= 65
        needed[:total] = 0
        needed[:high_season] = 0
        needed[:reason] = 'older_than_65'
      elsif roles.include?('SPL_INSTRUCTOR')
        needed[:total] = 0
        needed[:high_season] = 0
        needed[:reason] = 'instructor'
      elsif has_disability
        needed[:total] = 0
        needed[:high_season] = 0
        needed[:reason] = 'has_disability'
      elsif roles.include?('BOARD_MEMBER')
        needed[:total] = 0
        needed[:high_season] = 0
        needed[:reason] = 'board_member'
      elsif roles.include?('TUG_PILOT')
        needed[:total] = 1
        needed[:high_season] = 0
        needed[:reason] = 'tow_pilot'
      else
        needed[:total] = 2
        needed[:high_season] = 1
      end
    else
      # FALLBACK if there are no roles, REMOVE ME
      needed[:total] = 2
      needed[:high_season] = 1
    end

    needed
  end

  def roster_status(time:)
    year_model = Ygg::Acao::Year.find_by!(year: time.year)

    res = {
    }

    membership = memberships.find_by(reference_year: year_model)

    needed_entries_present = nil
    needed_total = nil
    needed_high_season = nil

    is_member = membership && (membership.status == 'MEMBER' || membership.status == 'WAITING_PAYMENT')

    roster_entries_needed = roster_entries_needed(time: time)
    needed_entries_present = roster_needed_entries_present(time: time)

    entries = roster_entries.joins(:roster_day).where('roster_days.date': (
      time.beginning_of_year..time.end_of_year
    ))

    entries_high = entries.where('roster_days.high_season')

    {
      year: time.year,
      can_select_entries: true,
      total: entries.count,
      high_season: entries_high.count,
      will_need_total: roster_entries_needed[:total],
      will_need_high_season: roster_entries_needed[:high_season],
      will_need_reason: roster_entries_needed[:reason],
      needed_total: is_member ? roster_entries_needed[:total] : nil,
      needed_high_season: is_member ? roster_entries_needed[:high_season] : nil,
      needed_entries_present: needed_entries_present,
    }
  end

  def active?(time: Time.now)
    memberships.any? { |x| x.active?(time: time) }
  end

  def active_to(time: Time.now)
    m = memberships.select { |x| x.active?(time: time) }.max { |x| x.valid_to }
    m ? m.valid_to : nil
  end

  def active_services(time: Time.now)
    services.where('valid_to IS NULL OR valid_to > ?', time).where('valid_from IS NULL OR valid_from < ?', time)
  end

  include Currency

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
      act << Ygg::Acao::Member.find_by!(code: 7024) # Special entry for Kicca
      act << Ygg::Acao::Member.find_by!(code: 7017) # Special entry for Matteo Negri
      act << Ygg::Acao::Member.find_by!(code: 7023) # Special entry for Clara

      Ygg::Ml::List.find_by!(symbol: 'ACTIVE_MEMBERS').sync_from_people!(people: act.compact.uniq)

      vot = voting_members.to_a
      vot << Ygg::Acao::Member.find_by!(code: 7002)

      Ygg::Ml::List.find_by!(symbol: 'VOTING_MEMBERS').sync_from_people!(people: vot.compact.uniq)
      Ygg::Ml::List.find_by!(symbol: 'STUDENTS').sync_from_people!(people: active_members.where(ml_students: true))
      Ygg::Ml::List.find_by!(symbol: 'INSTRUCTORS').sync_from_people!(people: active_members.where(ml_instructors: true))
      Ygg::Ml::List.find_by!(symbol: 'TUG_PILOTS').sync_from_people!(people: active_members.where(ml_tug_pilots: true))
      Ygg::Ml::List.find_by!(symbol: 'BOARD_MEMBERS').sync_from_people!(people: board_members)
    end

    transaction do
      Ygg::Ml::List.find_by!(symbol: 'ACTIVE_MEMBERS').sync_to_mailman!(list_name: 'soci')
#     Ygg::Ml::List.find_by!(symbol: 'STUDENTS'). sync_to_mailman!(list_name: 'scuola')
      Ygg::Ml::List.find_by!(symbol: 'INSTRUCTORS').sync_to_mailman!(list_name: 'istruttori')
#      Ygg::Ml::List.find_by!(symbol: 'BOARD_MEMBERS').sync_to_mailman!(list_name: 'consiglio')
      Ygg::Ml::List.find_by!(symbol: 'TUG_PILOTS').sync_to_mailman!(list_name: 'trainatori')
    end
  end

  class Media
    attr_accessor :id
    attr_accessor :number
    attr_accessor :code
    attr_accessor :code_for_faac
    attr_accessor :descr
    attr_accessor :member
    attr_accessor :member_id
    attr_accessor :enabled
    attr_accessor :validity_start
    attr_accessor :validity_end

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

  def access_validity_ranges(from: Time.now)
    ranges = RangeArray.new

    act_to = active_to

    if act_to
      ranges << (nil .. (act_to.round))
    end

    if socio.tessere_inizio || socio.tessere_fine
      ranges << ((socio.tessere_inizio && socio.tessere_inizio.beginning_of_day) ..
                 (socio.tessere_fine && socio.tessere_fine.end_of_day))
    end

#puts "Ranges #{ranges}"

    ranges = ranges.flatten
#puts "Ranges flattened #{ranges}"

    ranges.drop_while { |x| x.end && x.end < from }

    ranges
  end

  def self.sync_with_faac!(debug: Rails.application.config.acao.faac_debug || 0)

    if Rails.application.config.acao.faac_dry_run
      puts "FAAC dry run"
      return
    end

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

    Ygg::Toolkit.merge(l: l_records, r: r_records,
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
        mobile: l.person.contacts.where(type: 'mobile').first.try(:value),
#        email: l.person.contacts.where(type: 'email').first.try(:value),
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
    r_records_hash = Hash[r_records.map { |x| [ x[:identifier], x ] }]

    # l_records will be a union of medias from KeyFob and AccessRemote(s)
    l_records = []
    l_records += Ygg::Acao::KeyFob.all.
      select { |x| users[x.member_id] }.
      map { |x| Media.new(
        id: x.id,
        number: nil,
        code: x.code,
        member: users[x.member_id],
        member_id: x.member_id,
        code_for_faac: x.code_for_faac,
        enabled: x.validity_ranges.any?,
        validity_start: x.validity_start,
        validity_end: x.validity_end,
      )
    }

    Ygg::Acao::AccessRemote.all.each do |x|
      if users[x.member_id] && x.ch1_code
        l_records << Media.new(
          id: x.id,
          number: 10000 + (x.symbol.to_i * 10) + 1,
          code: x.ch1_code,
          member_id: x.member_id,
          member: users[x.member_id],
          code_for_faac: x.ch1_code_for_faac,
          enabled: x.validity_ranges.any?,
          validity_start: x.validity_start,
          validity_end: x.validity_end,
        )
      end

      if users[x.member_id] && x.ch2_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(x.id),
          number: 10000 + (x.symbol.to_i * 10) + 2,
          code: x.ch2_code,
          member_id: x.member_id,
          member: users[x.member_id],
          code_for_faac: x.ch2_code_for_faac,
          enabled: x.validity_ranges.any?,
          validity_start: x.validity_start,
          validity_end: x.validity_end,
        )
      end

      if users[x.member_id] && x.ch3_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(derive_uuid_from_uuid(x.id)),
          number: 10000 + (x.symbol.to_i * 10) + 3,
          code: x.ch3_code,
          member_id: x.member_id,
          member: users[x.member_id],
          code_for_faac: x.ch3_code_for_faac,
          enabled: x.validity_ranges.any?,
          validity_start: x.validity_start,
          validity_end: x.validity_end,
        )
      end

      if users[x.member_id] && x.ch4_code
        l_records << Media.new(
          id: derive_uuid_from_uuid(derive_uuid_from_uuid(derive_uuid_from_uuid(x.id))),
          number: 10000 + (x.symbol.to_i * 10) + 4,
          code: x.ch4_code,
          member_id: x.member_id,
          member: users[x.member_id],
          code_for_faac: x.ch4_code_for_faac,
          enabled: x.validity_ranges.any?,
          validity_start: x.validity_start,
          validity_end: x.validity_end,
        )
      end
    end

    # Remove media before adding to avoid identifier uniqueness issues

    Ygg::Toolkit.merge(
    l: l_records.sort_by { |x| x.code_for_faac },
    r: r_records.sort_by { |x| x[:identifier] },
    l_cmp_r: lambda { |l,r| l.code_for_faac <=> r[:identifier] },
    l_to_r: lambda { |l| },
    r_to_l: lambda { |r|
      if users[r[:userUuid]]
        puts "Media remove (dup identifier): #{r[:uuid]} OCT=#{r[:identifier]}" if debug > 0

        faac.media_remove(uuid: r[:uuid])
      else
        puts "Media #{r[:identifier]} assigned to external user #{r[:uuid]} #{r[:userLastAndFirstName]}" if debug >= 2
      end
    },
    lr_update: lambda { |l,r| }
    )

    Ygg::Toolkit.merge(
    l: l_records.sort_by { |x| x.id },
    r: r_records.sort_by { |x| x[:uuid] },
    l_cmp_r: lambda { |l,r| l.id <=> r[:uuid] },
    l_to_r: lambda { |l|
      puts "Media create: #{l.id} num=#{l.number} code=#{l.code} oct=#{l.code_for_faac}" if debug > 0

      if r_records_hash[l.code_for_faac]
        puts "DUPLICATE MEDIA??? #{r_records_hash[l.code_for_faac]}"
      else
        #ranges = l.member.access_validity_ranges
        #range = ranges.first

        #validity_start = range && range.begin && (range.begin.to_i * 1000) || 0
        #validity_end = range && range.end && (range.end.to_i * 1000) || 0
        #always_valid = FAAC_ACTIVE.include?(l.member.code)

        faac.media_create(data: {
          uuid: l.id,
          identifier: l.code_for_faac,
          mediaTypeCode: 0,
  #        number: l.number,
          enabled: l.enabled,
          validityStart: l.validity_start ? (l.validity_start.to_i * 1000) : 0,
          validityEnd: l.validity_end ? (l.validity_end.to_i * 1000) : 0,
          validityMode: l.validity_end ? 1 : 0,
          antipassbackEnabled: false,
          countingEnabled: true,
          userUuid: l.member_id,
          profileUuidOrName: 'eb3df410-0bbd-4eb7-ac86-389c177e065b',
          lifeCycleMode: 0,
        })
      end
    },
    r_to_l: lambda { |r|
      if users[r[:userUuid]]
        puts "Media remove: #{r[:uuid]} OCT=#{r[:identifier]}" if debug > 0

        faac.media_remove(uuid: r[:uuid])
      end
    },
    lr_update: lambda { |l,r|
      puts "Media update check #{l.id} #{l.code}" if debug > 1

      #ranges = l.member.access_validity_ranges
      #range = ranges.first

      #validity_start = range && range.begin && (range.begin.to_i * 1000) || 0
      #validity_end = range && range.end && (range.end.to_i * 1000) || 0
      #always_valid = FAAC_ACTIVE.include?(l.member.code)

      intended = {
        identifier: l.code_for_faac,
        mediaTypeCode: 0,
#        number: l.number,
        enabled: l.enabled,
        validityStart: l.validity_start ? (l.validity_start.to_i * 1000) : 0,
        validityEnd: l.validity_end ? (l.validity_end.to_i * 1000) : 0,
        validityMode: l.validity_end ? 1 : 0,
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
    run_notifications!
    run_bar_report!
    #run_flights_report!
  end

  def run_notifications!
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
  end

  def run_bar_report!
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
  end

  def run_flights_report!
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

  # Roles for which we are authoritative
  WP_AUTH_ROLES = [ 'src_acao', 'socio', 'trainatore', 'allievo', 'istruttore' ]

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

    updates = []

    puts "Computing changes..." if debug >= 1

    l_records = relation.joins(:person).includes(:person).
                         joins(:person => :contacts).includes(:person => :contacts).
                         joins(:person => :emails).includes(:person => :emails).
                         joins(:person => :credentials).sort_by { |x| x.code.to_s }
    r_records = data.select { |x| x[:roles].split(',').include?('src_acao') }.sort_by { |x| x[:user_login] }

    puts "Computing changes..." if debug >= 1

    Ygg::Toolkit.merge(l: l_records, r: r_records,
    l_cmp_r: lambda { |l,r| l.code.to_s <=> r[:user_login] },
    l_to_r: lambda { |l|
      puts "CREATE: #{l.code}" if debug >= 2

      updates << [
        l.code.to_s,
        l.person.emails.any? ? l.person.emails.first.email : '',
        l.person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first.password,
        l.person.first_name,
        l.person.last_name,
        l.person.name,
        l.wp_roles.join(','),
        l.code.to_s,
      ]
    },
    r_to_l: lambda { |r|
      puts "REMOVE: #{r[:user_login]}" if debug >= 2
    },
    lr_update: lambda { |l,r|
      puts "UPDATE CHK #{l.code}" if debug >= 2

      # All current roles
      r_roles = r[:roles].split(',').sort

      # Current roles for which we are authoritative
      r_our_roles = r_roles & WP_AUTH_ROLES

      roles = l.wp_roles

      new_roles = ((r_roles - WP_AUTH_ROLES) + roles).sort

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
        l.person.emails.any? ? l.person.emails.first.email : '',
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

  def wp_roles
    roles = [ 'src_acao' ]
    roles << 'socio' if active?
    roles << 'trainatore' if is_tug_pilot?
    roles << 'allievo' if is_spl_student?
    roles << 'istruttore' if is_spl_instructor?

    roles
  end

  ############ Old Database Synchronization

  BANNED_IDS = [-1, 0, 1, 4000, 4001, 7000, 8888, 9999]

  def self.sync_from_maindb!(force: false, debug: 0)

    l_records = Ygg::Acao::MainDb::Socio.where.not(codice_socio_dati_generale: BANNED_IDS).order(id_soci_dati_generale: :asc).lock
    r_records = self.where.not(code: BANNED_IDS).where('ext_id IS NOT NULL').order(ext_id: :asc).lock

    Ygg::Toolkit.merge(l: l_records, r: r_records,
    l_cmp_r: lambda { |l,r| l.id_soci_dati_generale <=> r.ext_id },
    l_to_r: lambda { |l|
      return if [ -1, 0, 1, 4000, 4001, 7000, 8888, 9999 ].include?(l.codice_socio_dati_generale)

      transaction do
        puts "MEMBER ADDING SOCIO ID=#{l.id_soci_dati_generale} CODICE=#{l.codice_socio_dati_generale}" if debug >= 1

        person = Ygg::Core::Person.new(
        )

        member = Ygg::Acao::Member.new(
          person: person,
          ext_id: l.id_soci_dati_generale,
          roster_allowed: true,
        )

        member.sync_from_maindb(l, person: person, force: force, debug: debug)

        member.save!
        person.save!

#        member.acl_entries << Ygg::Core::Person::AclEntry.new(member: member, role: 'owner')
        person.person_roles.find_or_create_by(global_role: Ygg::Core::GlobalRole.find_by_name('simple_interface'))

        member.send_welcome_message!

        puts "MEMBER ADDED #{member.awesome_inspect(plain: true)}" if debug >= 1
      end
    },
    r_to_l: lambda { |r|
      puts "MEMBER REMOVED SOCIO ID=#{r.ext_id} CODICE=#{r.code} #{r.first_name} #{r.last_name}" if debug >= 1
#          r.ext_id = r.ext_id
#          r.code = nil
#          r.save!
    },
    lr_update: lambda { |l,r|

      puts "MEMBER UPD CHK #{l.codice_socio_dati_generale} #{l.Nome} #{l.Cognome}" if debug >= 3

      if l.lastmod.floor(6) != r.lastmod ||
         l.visita.lastmod.floor(6) != r.visita_lastmod ||
         l.licenza.lastmod.floor(6) != r.licenza_lastmod || force
        transaction do
          p = r.person
          r.sync_from_maindb(l, person: p, force: force, debug: debug)
        end
      end
    })
  end

  def sync_from_maindb(other = socio, person: self.person, force: false, debug: 0)
    if other.lastmod.floor(6) != lastmod || force
      puts "MEMBER #{code} #{person.first_name} #{person.last_name} Checking (other #{(Time.now - other.lastmod).to_i} old)" if debug >= 1

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

      self.bollini = other.Acconto_Voli

      save! if new_record?

      sync_contacts(other, person: person, debug: debug)
      sync_credentials(other, debug: debug)

      Ygg::Toolkit.merge(
      l: socio.tessere.where('len(tag) > 0').where('len(tag) < 10').order('LOWER(tag)'),
      r: access_remotes,
      l_cmp_r: lambda { |l,r| l.tag.downcase <=> r.symbol },
      l_to_r: lambda { |l|
        puts "ACCESS_REMOTE ADD #{l.inspect}" if debug >= 2
        rem = Ygg::Acao::AccessRemote.find_by(symbol: l.tag.downcase)
        raise "Cannot find remote '#{l.tag.downcase}' from #{l.inspect}" if !rem

        rem.update(member_id: id)
      },
      r_to_l: lambda { |r|
        puts "ACCESS_REMOTE REMOVE #{r.inspect}" if debug >= 2
        r.update(member_id: nil)
      },
      lr_update: lambda { |l,r|
        puts "ACCESS_REMOTE #{l.inspect} => #{r.inspect}" if debug >= 2
      })

      if deep_changed?
        puts "MEMBER #{code} #{person.first_name} #{person.last_name} CHANGED" if debug >= 1
        puts deep_changes.awesome_inspect(plain: true)
      end

      self.lastmod = other.lastmod.floor(6)

      begin
        save!
      rescue ActiveRecord::RecordInvalid
        puts "VALIDATION ERROR: #{errors.inspect}"
        raise
      end

      if person.deep_changed?
        puts "  PERSON #{person.first_name} #{person.last_name} CHANGED" if debug >= 1
        puts person.deep_changes.awesome_inspect(plain: true) if debug >= 2
      end

      begin
        person.save!
      rescue ActiveRecord::RecordInvalid
        puts "VALIDATION ERROR: #{person.errors.inspect}"
        raise
      end
    end

    if self.licenza_lastmod != other.licenza.lastmod.floor(6) || force
      puts "MEMBER #{code} Checking licenses (other #{(Time.now - other.licenza.lastmod).to_i} old)" if debug >= 1

      if sync_licenses(other.licenza, debug: debug)
        puts "MEMBER #{code} #{person.first_name} #{person.last_name} LICENSES UPDATED" if debug >= 1
      end

      self.licenza_lastmod = other.licenza.lastmod.floor(6)
      save!
    end

    if self.visita_lastmod != other.visita.lastmod.floor(6) || force
      puts "MEMBER #{code} Checking medicals (other #{(Time.now - other.visita.lastmod).to_i} old)" if debug >= 1

      if sync_medicals(other.visita, debug: debug)
        puts "MEMBER #{code} #{person.first_name} #{person.last_name} MEDICALS UPDATED" if debug >= 1
      end

      self.sleeping = other.visita.socio_non_attivo
      self.bar_credit = other.visita.acconto_bar_euro

      if deep_changed?
        puts "MEMBER #{code} #{person.first_name} #{person.last_name} CHANGED" if debug >= 1
        puts deep_changes.awesome_inspect(plain: true)
      end

      self.visita_lastmod = other.visita.lastmod.floor(6)

      save!
    end
  end

  def sync_credentials(l, debug: 0)
    cred = person.credentials.where(sti_type: 'Ygg::Core::Person::Credential::ObfuscatedPassword').first

    pw = cred ? cred.password : Password.xkcd(words: 3, dict: VihaiPasswordRails.dict('it'))

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

  def sync_licenses(licenza = socio.licenza, debug: 0)
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
        rating = license.ratings.find_or_initialize_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'SLSS'))
        rating.issued_at = (licenza.data_abil_SL && licenza.data_abil_SL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.data_abil_SL.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'SLSS')).destroy_all
      end

      if licenza.Abilitazione_TMG_SiNo
        rating = license.ratings.find_or_initialize_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TMG'))
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TMG')).destroy_all
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
        rating = license.ratings.find_or_create_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TMG'))
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TMG'))
        rating.destroy if rating
      end

      if licenza.Abilitazione_Traino_SiNo
        rating = license.ratings.find_or_create_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TOW'))
        rating.issued_at = (licenza.Data_Abilit_Traino && licenza.Data_Abilit_Traino != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Traino.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'TOW'))
        rating.destroy if rating
      end

      if licenza.Abilit_Istruttore_SiNo
        rating = license.ratings.find_or_create_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'FI'))
        rating.issued_at = (licenza.Data_Abilit_Istruttore && licenza.Data_Abilit_Istruttore != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Istruttore.floor(0) : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(rating_type: Ygg::Acao::RatingType.find_by!(symbol: 'FI'))
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

  def sync_contacts(other, person:, debug: 0)
    if other.Email && !other.Email.strip.empty? && other.Email.strip != 'acao@acao.it' && other.Email.strip != 'NO'
      person.emails.find_or_create_by(email: other.Email.strip) do |email|
        email.ml_address = Ygg::Ml::Address.find_or_create_by(addr: other.Email.strip, addr_type: 'EMAIL') do |addr|
          addr.name = person.name
        end
      end
    end

    if other.Email && !other.Email.strip.empty? && other.Email.strip != 'acao@acao.it' && other.Email.strip != 'NO'
      person.contacts.find_or_create_by(type: 'email', value: other.Email.strip)
    end

    if other.Telefono_Casa && other.Telefono_Casa.strip != '' && other.Telefono_Casa.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: other.Telefono_Casa.strip, descr: 'Casa')
    end

    if other.Telefono_Ufficio && other.Telefono_Ufficio.strip != '' && other.Telefono_Ufficio.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: other.Telefono_Ufficio.strip, descr: 'Ufficio')
    end

    if other.Telefono_Altro && other.Telefono_Altro.strip != '' && other.Telefono_Altro.strip != '0'
      person.contacts.find_or_create_by(type: 'phone', value: other.Telefono_Altro.strip, descr: 'Ufficio')
    end

    if other.Telefono_Cellulare && other.Telefono_Cellulare.strip != '' && other.Telefono_Cellulare.strip != '0'
      person.contacts.find_or_create_by(type: 'mobile', value: other.Telefono_Cellulare.strip)
    end

    if other.Fax && other.Fax.strip != '' && other.Fax.strip != '0'
      person.contacts.find_or_create_by(type: 'fax', value: other.Fax.strip)
    end

    if other.Sito_Web && other.Sito_Web.strip != '' && other.Sito_Web.strip != 'W'
      person.contacts.find_or_create_by(type: 'url', value: other.Sito_Web.strip)
    end
  end

  def troiano_datetime_to_utc(dt)
    ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end

  def self.voting_members(time: Time.now)
    # active_members(time: time).where('birth_date < ?', time.to_date - 18.years)

    active_members(time: time)
  end

  def self.spl_students
    active_members.joins(:roles).where(roles: { symbol: 'SPL_STUDENT' })
  end

  def self.board_members
    active_members.joins(:roles).where(roles: { symbol: 'BOARD_MEMBER' })
  end

  def self.tug_pilots
    active_members.joins(:roles).where(roles: { symbol: 'TUG_PILOT' })
  end

  def roles_at(time:)
    roles.to_a.select { |x|
       (!x.valid_from || time > x.valid_from) &&
       (!x.valid_to || time < x.valid_to)
    }
  end

  def is_spl_student?
    roles.find_by(symbol: 'SPL_STUDENT')
  end

  def is_spl_instructor?
    roles.find_by(symbol: 'SPL_INSTRUCTOR')
  end

  def is_tug_pilot?
    roles.find_by(symbol: 'TUG_PILOT')
  end

  def is_board_member?
    roles.find_by(symbol: 'BOARD_MEMBER')
  end

  def is_fireman?
    roles.find_by(symbol: 'FIREMAN')
  end

end

end
end
