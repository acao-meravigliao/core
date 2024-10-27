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

class RosterDay < Ygg::PublicModel
  self.table_name = 'acao.roster_days'

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :integer, null: false, limit: 4 } ],
    [ :must_have_column, { name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "date", type: :date, default: nil, null: true}],
    [ :must_have_column, {name: "high_season", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "needed_people", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_index, {columns: ["uuid"], unique: true}],
    [ :must_have_index, {columns: ["date"], unique: true}],
  ]

  has_many :roster_entries,
           class_name: 'Ygg::Acao::RosterEntry'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def self.for_year(year = Time.now.year)
    where(date: Time.new(year).beginning_of_year..Time.new(year).end_of_year)
  end

  def self.init_for_year(year: Time.now.year)

    # Alta stagione 1/3 => 30/9 (4 persone)
    # Da metà febbraio 3 persone
    # Ottobre 3 persone
    #
    # Ognisanti
    # Ferragosto
    # Due giugno
    # Primo maggio
    # Pasquetta
    # Immacolata
    # 25 aprile
    # Befana
    # primo gennaio
    # patrono 8 maggio (3 persone)

    day = Time.new(year).beginning_of_week
    day = day.next_week if day.year < year

    transaction do
      while day.year == year do

        high_season = day.between?(Time.new(day.year, 3, 1).beginning_of_day, Time.new(day.year, 7, 7).end_of_day)

        if high_season
          needed_people = 4
        elsif day.between?(Time.new(day.year, 10, 1).beginning_of_day, Time.new(day.year, 11, 1).beginning_of_day)
          needed_people = 3
        elsif day.between?(Time.new(day.year, 2, 15).beginning_of_day, Time.new(day.year, 3, 1).beginning_of_day)
          needed_people = 3
        else
          needed_people = 2
        end

        if (day + 5.days).year == year # Saturday
          create_day(date: day + 5.days, high_season: high_season, needed_people: needed_people)
        end

        if (day + 6.days).year == year # Sunday
          create_day(date: day + 6.days, high_season: high_season, needed_people: needed_people)
        end

        day += 1.week
      end

      create_day(date: Time.new(year, 1, 1), high_season: false, needed_people: 2, descr: 'Capodanno')
      create_day(date: Time.new(year, 1, 6), high_season: false, needed_people: 2, descr: 'Epifania')
      create_day(date: Time.new(year, 4, 25), high_season: true, needed_people: 4, descr: 'Liberazione')
      create_day(date: Time.new(year, 5, 1), high_season: true, needed_people: 4, descr: 'Festa del Lavoro')
      create_day(date: Time.new(year, 5, 8), high_season: true, needed_people: 3, descr: 'Patrono di Varese')
      create_day(date: Time.new(year, 6, 2), high_season: true, needed_people: 4, descr: 'Festa della Repubblica')
      create_day(date: Time.new(year, 8, 15), high_season: true, needed_people: 2, descr: 'Ferragosto')
      create_day(date: Time.new(year, 11, 1), high_season: false, needed_people: 2, descr: 'Ognisanti')
      create_day(date: Time.new(year, 12, 8), high_season: false, needed_people: 2, descr: 'Immacolata concezione')
    end
  end

  def self.create_day(**args)
    create(**args) unless find_by(date: args[:date])
  end

  def check_and_mark_chief!
    unless roster_entries.where(chief: true).any?
      entry = roster_entries.to_a.sort { |a,b| b.person.birth_date <=> a.person.birth_date }.first { |x| x.person.acao_roster_chief }
      if entry
        entry.chief = true
        entry.save!
      end
    end
  end

  def daily_form_pdf
   pdf = DailyPdfForm.new(day: self, page_size: 'A4', page_layout: :portrait)
   pdf.draw
   str = pdf.render

   str
  end

  def print_daily_form
    pdfstr = daily_form_pdf

    IO.popen([ '/usr/bin/lpr', "-P#{Rails.application.config.acao.printer}" ], File::WRONLY, encoding: Encoding::ASCII_8BIT) do |io|
      io.write(pdfstr)
    end
  end
end

end
end
