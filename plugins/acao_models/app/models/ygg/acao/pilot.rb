#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'vihai_password_rails'


module Ygg
module Acao

class Pilot < Ygg::Core::Person

  self.porn_migration += [
    [ :must_have_column, {name: "acao_ext_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "acao_code", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "acao_last_notify_run", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "acao_sleeping", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_debtor", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_bar_credit", type: :decimal, default: 0.0, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "acao_bollini", type: :decimal, default: 0.0, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "acao_bar_last_summary", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "acao_roster_chief", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_roster_allowed", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_is_student", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_is_tug_pilot", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_is_board_member", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_is_instructor", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_is_fireman", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_has_disability", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_email_allowed", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_job", type: :string, null: true}],
    [ :must_have_column, {name: "acao_ml_students", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_ml_instructors", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_ml_tug_pilots", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_ml_blabla", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "acao_ml_secondoperiodo", type: :boolean, default: false, null: false}],
    [ :must_have_index, {columns: ["acao_code"], unique: true, name: "core_people_acao_code_idx"}],
    [ :must_have_index, {columns: ["acao_ext_id"], unique: true, name: "index_core_people_on_acao_ext_id"}],
  ]

  has_many :acao_services,
           class_name: '::Ygg::Acao::MemberService',
           foreign_key: 'person_id'

  has_many :acao_licenses,
           class_name: '::Ygg::Acao::License'

  has_many :acao_medicals,
           class_name: '::Ygg::Acao::Medical'

  has_many :acao_fai_cards,
           class_name: '::Ygg::Acao::FaiCard',
           foreign_key: :person_id

  has_many :acao_bar_transactions,
           class_name: '::Ygg::Acao::BarTransaction',
           foreign_key: 'person_id'

  has_many :acao_token_transactions,
           class_name: '::Ygg::Acao::TokenTransaction',
           foreign_key: 'person_id'

  has_many :acao_aircrafts,
           class_name: '::Ygg::Acao::Aircraft',
           foreign_key: 'owner_id'

  has_many :acao_flights,
           class_name: '::Ygg::Acao::Flight',
           foreign_key: 'pilot1_id'

  has_many :acao_flights_as_pilot2,
           class_name: '::Ygg::Acao::Flight',
           foreign_key: 'pilot2_id'

  has_many :acao_trailers,
           class_name: '::Ygg::Acao::Trailer',
           foreign_key: 'person_id'

  has_many :acao_key_fobs,
           class_name: '::Ygg::Acao::KeyFob',
           foreign_key: 'person_id'

  # Old DB
  belongs_to :acao_socio,
             class_name: '::Ygg::Acao::MainDb::Socio',
             primary_key: 'id_soci_dati_generale',
             foreign_key: 'acao_ext_id',
             optional: true

  def self.lc_class_name
    'Ygg::Core::Person'
  end

  def self.active_members(time: Time.now)
    members = Ygg::Acao::Pilot.
                where.not('acao_sleeping').
                where('EXISTS (SELECT * FROM acao.memberships WHERE acao.memberships.person_id=core.people.id ' +
                        'AND ? BETWEEN acao.memberships.valid_from AND acao.memberships.valid_to)', time)

    members
  end

  # List of members that have at least a membership for reference year 'year'.
  # This includes students which only have 6-months subscription, maybe in the past and may not be currently active
  #
  def self.members_for_year(year: Time.now.year, status: 'MEMBER')
    year = Ygg::Acao::Year.find_by!(year: year) unless year.is_a?(Ygg::Acao::Year)

    members = Ygg::Acao::Pilot.
                where.not('acao_sleeping').
                where('EXISTS (SELECT * FROM acao.memberships WHERE acao.memberships.person_id=core.people.id ' +
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

    if birth_date && compute_completed_years(birth_date, ym.renew_opening_time) >= 65
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'Età maggiore di 65 anni'
    elsif acao_is_instructor
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = 'Istruttore'
    elsif acao_has_disability
      needed[:total] = 0
      needed[:high_season] = 0
      needed[:reason] = ''
    elsif acao_is_board_member
      needed[:total] = 1
      needed[:high_season] = 0
      needed[:reason] = 'Membro del consiglio'
    elsif acao_is_tug_pilot
      needed[:total] = 1
      needed[:high_season] = 0
      needed[:reason] = 'Trainatore'
    end

    needed
  end

  # Verifica che i turni di linea necessari siano stati selezionati
  #
  def roster_needed_entries_present(year: Time.now.year)
    needed = roster_entries_needed(year: year)

    roster_entries = acao_roster_entries.joins(:roster_day).where('roster_days.date': (
      DateTime.new(year).beginning_of_year..DateTime.new(year).end_of_year
    ))

    roster_entries_high = roster_entries.where('roster_days.high_season')

    roster_entries.count >= needed[:total] && roster_entries_high.count >= needed[:high_season]
  end

  def acao_send_initial_password!
    credential = credentials.where('fqda LIKE \'%@cp.acao.it\'').first

    return if !credential

    Ygg::Ml::Msg.notify(destinations: self, template: 'SEND_INITIAL_PASSWORD', template_context: {
      first_name: first_name,
      password: credential.password,
     }, objects: self)
  end

  def send_welcome_message!
    return if acao_sleeping

    credential = credentials.where('fqda LIKE \'%@cp.acao.it\'').first

    return if !credential

    Ygg::Ml::Msg.notify(destinations: self, template: 'WELCOME', template_context: {
      first_name: first_name,
      password: credential.password,
      code: acao_code,
     }, objects: self)
  end

  def send_happy_birthday!
    Ygg::Ml::Msg::Email.notify(destinations: self, template: 'HAPPY_BIRTHDAY', template_context: {
      first_name: first_name,
    })
  end


  ########### Notifications & Chores

  def self.run_chores!
    where.not('acao_sleeping').each do |person|
      person.run_chores!
    end

    transaction do
      act = active_members.to_a
      act << Ygg::Core::Person.find_by(acao_code: 7009) # Special entry for Daniela
      act << Ygg::Core::Person.find_by(acao_code: 7020) # Special entry for Annalisa
      act << Ygg::Core::Person.find_by(acao_code: 554) # Special entry for Fabio
      act << Ygg::Core::Person.find_by(acao_code: 7006) # Special entry for Ale
      act << Ygg::Core::Person.find_by(acao_code: 7017) # Special entry for Matteo Negri

      sync_ml!(symbol: 'ACTIVE_MEMBERS', members: act.compact.uniq)

      vot = voting_members.to_a
      vot << Ygg::Core::Person.find_by(acao_code: 7009)

      sync_ml!(symbol: 'VOTING_MEMBERS', members: vot.compact.uniq)

      sync_ml!(symbol: 'STUDENTS', members: active_members.where(acao_ml_students: true))
      sync_ml!(symbol: 'INSTRUCTORS', members: active_members.where(acao_ml_instructors: true))
      sync_ml!(symbol: 'TUG_PILOTS', members: active_members.where(acao_ml_tug_pilots: true))
      sync_ml!(symbol: 'BOARD_MEMBERS', members: board_members)
    end

    transaction do
      sync_mailman!(list_name: 'soci', symbol: 'VOTING_MEMBERS')
#      sync_mailman!(list_name: 'allievi', symbol: 'STUDENTS')
      sync_mailman!(list_name: 'istruttori', symbol: 'INSTRUCTORS')
#      sync_mailman!(list_name: 'consiglio', symbol: 'BOARD_MEMBERS')
      sync_mailman!(list_name: 'trainatori', symbol: 'TUG_PILOTS')
    end

    sync_to_acao_for_wp!
  end

  def run_chores!
    transaction do
      now = Time.now
      last_run = acao_last_notify_run || Time.new(0)

      run_roster_notification(now: now, last_run: last_run)

      if birth_date && (birth_date + 10.hours).between?(last_run, now) &&
         birth_date.to_date == now.to_date # Otherwise it's too late
        send_happy_birthday!
      end

#      run_license_expirations(now: now, last_run: last_run)
#      run_medical_expirations(now: now, last_run: last_run)

      self.acao_last_notify_run = now

      save!
    end

    transaction do
      now = Time.now
      last_run = acao_bar_last_summary || Time.new(0)

      when_during_day = now.beginning_of_day # Midnight

      if when_during_day.between?(last_run, now)
        send_bar_transactions!(from: last_run, to: now.end_of_day)

        self.acao_bar_last_summary = now
        save!
      end
    end
  end

  def run_roster_notification(now:, last_run:)
    when_in_advance_sms = 1.days - 10.hours
    when_in_advance_mail = 7.days - 10.hours

    acao_roster_entries.each do |entry|
      if (entry.roster_day.date.beginning_of_day - when_in_advance_mail).between?(last_run, now) &&
          entry.roster_day.date > now # Oops, too late
        Ygg::Ml::Msg::Email.notify(destinations: self, template: 'ROSTER_NEAR_NOTIFICATION', template_context: {
          first_name: first_name,
          date: entry.roster_day.date,
        })
      end

      if (entry.roster_day.date.beginning_of_day - when_in_advance_sms).between?(last_run, now) &&
         entry.roster_day.date > now # Oops, too late
        Ygg::Ml::Msg::Sms.notify(destinations: self, template: 'ROSTER_NEAR_NOTIFICATION_SMS', template_context: {
          first_name: first_name,
          date: entry.roster_day.date,
        })
      end
    end
  end

  def run_license_expirations(now:, last_run:)
    when_in_advance = 14.days - 10.hours

    acao_licenses.each do |license|
      context = {
        first_name: first_name,
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

          Ygg::Ml::Msg::Email.notify(destinations: self, template: template, template_context: context)
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
            Ygg::Ml::Msg::Email.notify(destinations: self, template: template, template_context: context.merge({
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

          Ygg::Ml::Msg::Email.notify(destinations: self, template: template, template_context: context.merge({
            raing_type: rating.type,
            raing_valid_to: rating.valid_to ? rating.valid_to.strftime('%d-%m-%Y') : 'N/A',
          }))
        end
      end
    end
  end

  def run_medical_expirations(now:, last_run:)
    when_in_advance = 14.days - 10.hours

    acao_medicals.each do |medical|
      template = nil

      if medical.valid_to.beginning_of_day.between?(last_run, now)
        template = 'MEDICAL_EXPIRED'
      elsif (medical.valid_to.beginning_of_day - when_in_advance).between?(last_run, now)
        template = 'MEDICAL_EXPIRING'
      end

      if template
        Ygg::Ml::Msg::Email.notify(destinations: self, template: template, template_context: {
          first_name: first_name,
          medical_type: medical.type,
          medical_identifier: medical.identifier,
          medical_issued_at: medical.issued_at ? medical.issued_at.strftime('%d-%m-%Y') : 'N/A',
          medical_valid_to: medical.valid_to ? medical.valid_to.strftime('%d-%m-%Y') : 'N/A',
        })
      end
    end
  end

  def check_bar_transactions
    xacts = acao_bar_transactions.order(recorded_at: :asc, old_id: :asc, old_cassetta_id: :asc)

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

  def send_bar_transactions!(from:, to:)
    xacts = acao_bar_transactions.where(recorded_at: from..to).order(recorded_at: :asc)

    return if xacts.count == 0

    # To be removed when log entries have credit,prev_credit chain
    starting_credit = acao_bar_credit - acao_bar_transactions.where('recorded_at > ?', from).reduce(0) { |a,x| a + x.amount }

    Ygg::Ml::Msg::Email.notify(destinations: self, template: 'BAR_SUMMARY', template_context: {
      first_name: first_name,
      date: xacts.first.recorded_at.strftime('%d-%m-%Y'),
      starting_credit: starting_credit,
      xacts: xacts,
    })
  end

  ########## Mailing lists synchronization

  def self.sync_ml!(symbol:, members:, time: Time.now)
    list = Ygg::Ml::List.find_by!(symbol: symbol)
    current_members = list.members.where(owner_type: 'Ygg::Core::Person').order(owner_id: :asc)

    merge(l: members, r: current_members,
      l_cmp_r: lambda { |l,r| l.id <=> r.owner_id },
      l_to_r: lambda { |l|
        l.contacts.where(type: 'email').each do |contact|
          addr = Ygg::Ml::Address.find_or_create_by(addr: contact.value, addr_type: 'EMAIL')
          addr.name = l.name
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
        r.address.name = l.name
        r.address.save!
      },
    )
  end

  def self.sync_mailman!(symbol:, list_name:, dry_run: Rails.application.config.acao.soci_ml_dry_run)

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

  def self.sync_to_acao_for_wp!(relation: active_members)
    data = ''

    IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'lino@iserver.acao.it', '/usr/local/bin/wp', '--skip-plugins', '--path=/srv/hosting/links/acao.it/htdocs',
                'user', 'import-csv', '-' ], 'r+') do |io|

      io.write("user_login,user_email,display_name,user_pass,first_name,last_name\n")

      relation.each do |m|
        user = [
          m.acao_code.to_s,
          m.acao_code.to_s + '@acao.it',
          #m.contacts.where(type: 'email').any? ? m.contacts.where(type: 'email').first.value : '',
          m.name,
          m.credentials.where('fqda LIKE \'%@cp.acao.it\'').first.password,
          m.first_name,
          m.last_name,
        ]

        io.write(user.join(',') + "\n")
      end

      io.close_write

      data = io.read
      io.close

      if !$?.success?
        raise "Cannot update wordpress users: #{data}"
      end
    end

    data
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

  def self.sync_from_maindb!(with_logbar: true, with_logbollini: true)

    l_records = Ygg::Acao::MainDb::Socio.order(id_soci_dati_generale: :asc).lock
    r_records = Ygg::Acao::Pilot.where('acao_ext_id IS NOT NULL').order(acao_ext_id: :asc).lock

    transaction do
      merge(l: l_records, r: r_records,
      l_cmp_r: lambda { |l,r| l.id_soci_dati_generale <=> r.acao_ext_id },
      l_to_r: lambda { |l|
        return if [ 0, 1, 4000, 4001, 7000, 8888, 9999 ].include?(l.codice_socio_dati_generale)

        puts "ADDING SOCIO ID=#{l.id_soci_dati_generale} CODICE=#{l.codice_socio_dati_generale}"

        person = Ygg::Acao::Pilot.new({
          acao_ext_id: l.id_soci_dati_generale,
          acao_roster_allowed: true,
        })

        person.sync_from_maindb(l, with_logbar: with_logbar, with_logbollini: with_logbollini)

        person.save!

#        person.acl_entries << Ygg::Core::Person::AclEntry.new(person: person, role: 'owner')
        person.person_roles.find_or_create_by(global_role: Ygg::Core::GlobalRole.find_by_name('simple_interface'))

        person.send_welcome_message!

        puts "ADDED #{person.awesome_inspect(plain: true)}"
      },
      r_to_l: lambda { |r|
#puts "REMOVED SOCIO #{l.first_name} #{l.last_name} L_ID=#{l.acao_ext_id} R_ID=#{r.id_soci_dati_generale}"
#          r.acao_ext_id = r.acao_ext_id
#          r.acao_code = nil
#          r.save!
      },
      lr_update: lambda { |l,r|

        if l.lastmod != r.acao_lastmod || l.visita.lastmod != r.acao_visita_lastmod
          r.sync_from_maindb(l, with_logbar: with_logbar, with_logbollini: with_logbollini)

          if r.deep_changed?
            puts "UPDATING #{l.id_soci_dati_generale} <=> #{r.acao_ext_id} (#{r.first_name} #{r.last_name})"
            puts r.deep_changes.awesome_inspect(plain: true)
          end

          r.acao_lastmod = l.lastmod
          r.acao_visita_lastmod = l.visita.lastmod
          r.acao_licenza_lastmod = l.licenza.lastmod
          r.save!
        end
      })
    end
  end

  def sync_from_maindb(other = acao_socio, with_logbar: true, with_logbollini: true)
    self.first_name = (other.Nome.blank? ? '?' : other.Nome).strip.split(' ').first
    self.middle_name = (other.Nome.blank? ? '?' : other.Nome).strip.split(' ')[1..-1].join(' ')
    self.last_name = other.Cognome.strip
    self.gender = other.Sesso
    self.birth_date = other.Data_Nascita != Date.parse('1900-01-01 00:00:00 UTC') ? other.Data_Nascita : nil

    self.italian_fiscal_code = (other.Codice_Fiscale.strip != 'NO' &&
                                other.Codice_Fiscale.strip != 'non specificato' &&
                                !other.Codice_Fiscale.strip.blank?) ? other.Codice_Fiscale.strip : nil

    self.acao_code = other.codice_socio_dati_generale

    self.acao_job = (other.Professione.strip != 'non specificata' &&
                     other.Professione.strip != 'NO' &&
                     other.Professione.strip != 'NESSUNA' &&
                     !other.Professione.strip.blank?) ? other.Professione.strip : nil

    raw_address = [ other.Nato_a ].map { |x| x.strip }.
                  reject { |x| x.downcase == 'non specificato' || x.downcase == 'non specificata' || x == '?' }

    if raw_address.any? && other.Citta != 'CITTA' && other.Via != 'VIA'
      raw_address = raw_address.join(', ')
      if !birth_location || birth_location.raw_address != raw_address
        self.birth_location = Ygg::Core::Location.new_for(raw_address)
        sleep 0.3
      end
    else
      self.birth_location = nil
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

    self.acao_sleeping = other.visita.socio_non_attivo
    self.acao_bollini = other.Acconto_Voli
    self.acao_bar_credit = other.visita.acconto_bar_euro

    if other.tag_code &&  other.tag_code.strip != '0' && other.tag_code.strip != ''
      acao_key_fobs.find_or_initialize_by(code: other.tag_code.strip.upcase)
    else
      acao_key_fobs.destroy_all
    end

    save! if deep_changed?

    sync_contacts(other)
 #   sync_memberships(other.iscrizioni)
    sync_credentials(other)
    sync_licenses(other.licenza)
    sync_medicals(other.visita)

    if with_logbar
      sync_log_bar(other.log_bar2)
      sync_log_bar_deposits(other.cassetta_bar_locale)
    end

    if with_logbollini
      sync_log_bollini(other.log_bollini)
    end
  end

  def sync_log_bar(other_log_bar)
    self.class.merge(
      l: other_log_bar.order(id_logbar: :asc).lock,
      r: acao_bar_transactions.where('old_id IS NOT NULL').order(old_id: :asc).lock,
      l_cmp_r: lambda { |l,r| l.id_logbar <=> r.old_id },
      l_to_r: lambda { |l|
        acao_bar_transactions << Ygg::Acao::BarTransaction.new(
          recorded_at: troiano_datetime_to_utc(l.data_reg),
          cnt: 1,
          unit: '€',
          descr: l.descrizione.strip,
          amount: -l.prezzo,
          prev_credit: l.credito_prec,
          credit: l.credito_rim,
          old_id: l.id_logbar,
        )
      },
      r_to_l: lambda { |r|
        puts "Unexpected record in log bar"
        r.destroy
      },
      lr_update: lambda { |l,r|
        r.assign_attributes(
          recorded_at: troiano_datetime_to_utc(l.data_reg),
        )

        if r.deep_changed?
          puts "UPDATING LOG BAR from logbar2 id_logbar=#{l.id_logbar}"
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      }
    )
  end

  def sync_log_bar_deposits(other_deposits)
    self.class.merge(
      l: other_deposits.order(id_cassetta_bar_locale: :asc).lock,
      r: acao_bar_transactions.where('old_cassetta_id IS NOT NULL').order(old_cassetta_id: :asc).lock,
      l_cmp_r: lambda { |l,r| l.id_cassetta_bar_locale <=> r.old_cassetta_id },
      l_to_r: lambda { |l|
        acao_bar_transactions << Ygg::Acao::BarTransaction.new(
          recorded_at: troiano_datetime_to_utc(l.data_reg),
          cnt: 1,
          unit: '€',
          descr: 'Versamento',
          amount: l.avere_cassa_bar_locale,
          prev_credit: nil,
          credit: nil,
          old_cassetta_id: l.id_cassetta_bar_locale,
        )
      },
      r_to_l: lambda { |r|
        puts "Unexpected record in log bar deposits"
        r.destroy
      },
      lr_update: lambda { |l,r|
        r.assign_attributes(
          recorded_at: troiano_datetime_to_utc(l.data_reg),
        )

        if r.deep_changed?
          puts "UPDATING LOG BAR old_cassetta_id=#{l.id_cassetta_bar_locale}"
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      }
    )
  end

  def sync_log_bollini(other)
    self.class.merge(
      l: other.order(id_log_bollini: :asc).lock,
      r: acao_token_transactions.reload.where('old_id IS NOT NULL').order(old_id: :asc).lock,
      l_cmp_r: lambda { |l,r| l.id_log_bollini <=> r.old_id },
      l_to_r: lambda { |l|
        aircraft_reg = l.marche_mezzo.strip.upcase
        aircraft_reg = nil if aircraft_reg == 'NO' || aircraft_reg.blank?

        acao_token_transactions << Ygg::Acao::TokenTransaction.new(
          recorded_at: troiano_datetime_to_utc(l.log_data),
          old_operator: l.operatore.strip,
          old_marche_mezzo: l.marche_mezzo.strip,
          descr: l.note.strip,
          amount: l.credito_att - l.credito_prec,
          prev_credit: l.credito_prec,
          credit: l.credito_att,
          old_id: l.id_log_bollini,
          aircraft: Ygg::Acao::Aircraft.find_by(registration: aircraft_reg),
        )
      },
      r_to_l: lambda { |r|
      },
      lr_update: lambda { |l,r|
        aircraft_reg = l.marche_mezzo.strip.upcase
        aircraft_reg = nil if aircraft_reg == 'NO' || aircraft_reg.blank?

        r.assign_attributes(
          amount: l.credito_att - l.credito_prec,
          recorded_at: troiano_datetime_to_utc(l.log_data),
          aircraft: Ygg::Acao::Aircraft.find_by(registration: aircraft_reg),
        )

        if r.deep_changed?
          puts "UPDATING LOG BOLLINI old_cassetta_id=#{l.id_log_bollini}"
          puts r.deep_changes.awesome_inspect(plain: true)
          r.save!
        end
      }
    )
  end

  def sync_credentials(l)
    pw = Password.xkcd(words: 3, dict: VihaiPasswordRails.dict('it'))

    sync_credential("#{l.codice_socio_dati_generale.to_s}@cp.acao.it", pw)

    if l.Email && !l.Email.strip.empty? && l.Email.strip != 'acao@acao.it' && l.Email.strip != 'NO'
      sync_credential(l.Email.strip, pw)
    end
  end

  def sync_credential(fqda, pw)
    cred = credentials.find_by(fqda: fqda)
    if !cred
      credentials << Ygg::Core::Person::Credential::ObfuscatedPassword.new({
        fqda: fqda,
        password: pw,
      })
    end
  end

  def sync_memberships(iscrizioni)
    iscrizioni.each do |x|
      acao_memberships.find_or_create_by(year: x.anno_iscrizione)
    end
  end

  def sync_licenses(licenza)
    if licenza.GL_SiNo && licenza.Numero_GL.strip.upcase != 'ALLIEVO' && licenza.Numero_GL.strip.upcase != 'TRAINATORE' && licenza.Numero_GL.strip != 'I-GL-?'  && licenza.Numero_GL.strip != 'I-GL-'

      identifier = (licenza.Numero_GL && licenza.Numero_GL != ''  && licenza.Numero_GL != '0') ? licenza.Numero_GL.strip : nil
      license = acao_licenses.find_or_initialize_by(type: 'GPL', identifier: identifier)

      license.issued_at = licenza.Data_Rilascio_GL && licenza.Data_Rilascio_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Data_Rilascio_GL : nil

      license.valid_to = licenza.Scadenza_GL && licenza.Scadenza_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                         licenza.Scadenza_GL : nil

      license.valid_to2 = licenza.Annotazione_GL && licenza.Annotazione_GL != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Annotazione_GL : nil

      if licenza.abilitazioneSL_SiNo
        rating = license.ratings.find_or_initialize_by(type: 'SLSS')
        rating.issued_at = (licenza.data_abil_SL && licenza.data_abil_SL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.data_abil_SL : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(type: 'SLSS').destroy_all
      end

      if licenza.Abilitazione_TMG_SiNo
        rating = license.ratings.find_or_initialize_by(type: 'TMG')
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG : nil
        rating.valid_to = nil
        rating.save!
      else
        license.ratings.where(type: 'TMG').destroy_all
      end

      license.save!
    else
      acao_licenses.where(type: 'GPL').destroy_all
    end

    if licenza.PPL_Si_No &&
      identifier = (licenza.Numero_PPL && licenza.Numero_PPL.strip != ''  && licenza.Numero_PPL.strip != '0') ? licenza.Numero_PPL.strip : nil

      license = acao_licenses.find_or_create_by(type: 'PPL', identifier: identifier)

      license.issued_at = licenza.Data_Rilascio_PPL && licenza.Data_Rilascio_PPL != Date.parse('1900-01-01 00:00:00 UTC') ?
                         licenza.Data_Rilascio_PPL : nil

      license.valid_to = (licenza.Scadenza_PPL && licenza.Scadenza_PPL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                         licenza.Scadenza_PPL : nil

      license.valid_to2 = (licenza.scadenza_retraining_PPL && licenza.scadenza_retraining_PPL != Date.parse('1900-01-01 00:00:00 UTC')) ?
                         licenza.scadenza_retraining_PPL : nil

      if licenza.Abilitazione_TMG_SiNo
        rating = license.ratings.find_or_create_by(type: 'TMG')
        rating.issued_at = (licenza.DataAbilit_TMG && licenza.DataAbilit_TMG != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.DataAbilit_TMG : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'TMG')
        rating.destroy if rating
      end

      if licenza.Abilitazione_Traino_SiNo
        rating = license.ratings.find_or_create_by(type: 'TOW')
        rating.issued_at = (licenza.Data_Abilit_Traino && licenza.Data_Abilit_Traino != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Traino : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'TOW')
        rating.destroy if rating
      end

      if licenza.Abilit_Istruttore_SiNo
        rating = license.ratings.find_or_create_by(type: 'FI')
        rating.issued_at = (licenza.Data_Abilit_Istruttore && licenza.Data_Abilit_Istruttore != Date.parse('1900-01-01 00:00:00 UTC')) ?
                           licenza.Data_Abilit_Istruttore : nil
        rating.valid_to = nil
        rating.save!
      else
        rating = license.ratings.find_by(type: 'FI')
        rating.destroy if rating
      end

      license.save!
    else
      acao_licenses.where(type: 'PPL').destroy_all
    end

    if licenza.Tessera_FAI_SiNo && licenza.Numero_FAI.strip.upcase != 'FAI' && licenza.Numero_FAI.strip.upcase != '?' && licenza.Numero_GL.strip.upcase != 'D?'
      identifier = (licenza.Numero_FAI && licenza.Numero_FAI != ''  && licenza.Numero_FAI != '0') ? licenza.Numero_FAI.strip : nil
      fai_card = acao_fai_cards.find_or_initialize_by(identifier: identifier)

      fai_card.issued_at = licenza.Data_Rilascio_FAI && licenza.Data_Rilascio_FAI != Date.parse('1900-01-01 00:00:00 UTC') ?
                          licenza.Data_Rilascio_FAI : nil
      fai_card.country = 'IT'
      fai_card.valid_to = fai_card.issued_at.end_of_year

      fai_card.save!
    else
      acao_fai_cards.destroy_all
    end

  end

  def sync_medicals(visita)
    type = "IT class #{visita.Tipo_Classe_Visita}"

    if visita && visita.Scadenza_Visita_Medica && visita.Scadenza_Visita_Medica != Date.parse('1900-01-01 00:00:00 UTC')

      medical = acao_medicals.find_or_create_by(type: type)

      medical.issued_at = visita.Data_prima_Visita && visita.Data_prima_Visita != Date.parse('1900-01-01 00:00:00 UTC') ?
                          visita.Data_prima_Visita : nil

      medical.valid_to = visita.Scadenza_Visita_Medica && visita.Scadenza_Visita_Medica != Date.parse('1900-01-01 00:00:00 UTC') ?
                         visita.Scadenza_Visita_Medica : nil

      medical.save!
    else
      acao_medicals.where(type: type).destroy_all
    end
  end

  def sync_contacts(r)
    if r.Email && !r.Email.strip.empty? && r.Email.strip != 'acao@acao.it' && r.Email.strip != 'NO'
      contacts.find_or_create_by(type: 'email', value: r.Email.strip)
    end

    if r.Telefono_Casa && r.Telefono_Casa.strip != '' && r.Telefono_Casa.strip != '0'
      contacts.find_or_create_by(type: 'phone', value: r.Telefono_Casa.strip, descr: 'Casa')
    end

    if r.Telefono_Ufficio && r.Telefono_Ufficio.strip != '' && r.Telefono_Ufficio.strip != '0'
      contacts.find_or_create_by(type: 'phone', value: r.Telefono_Ufficio.strip, descr: 'Ufficio')
    end

    if r.Telefono_Altro && r.Telefono_Altro.strip != '' && r.Telefono_Altro.strip != '0'
      contacts.find_or_create_by(type: 'phone', value: r.Telefono_Altro.strip, descr: 'Ufficio')
    end

    if r.Telefono_Cellulare && r.Telefono_Cellulare.strip != '' && r.Telefono_Cellulare.strip != '0'
      contacts.find_or_create_by(type: 'mobile', value: r.Telefono_Cellulare.strip)
    end

    if r.Fax && r.Fax.strip != '' && r.Fax.strip != '0'
      contacts.find_or_create_by(type: 'fax', value: r.Fax.strip)
    end

    if r.Sito_Web && r.Sito_Web.strip != '' && r.Sito_Web.strip != 'W'
      contacts.find_or_create_by(type: 'url', value: r.Sito_Web.strip)
    end
  end

  def troiano_datetime_to_utc(dt)
    ActiveSupport::TimeZone.new('Europe/Rome').local_to_utc(dt)
  end

  def self.voting_members(time: Time.now)
    active_members.where('birth_date < ?', time.to_date - 18.years)
  end

  def self.students
    active_members.where(acao_is_student: true)
  end

  def self.board_members
    active_members.where(acao_is_board_member: true)
  end

  def self.tug_pilots
    active_members.where(acao_is_tug_pilot: true)
  end

end

end
end
