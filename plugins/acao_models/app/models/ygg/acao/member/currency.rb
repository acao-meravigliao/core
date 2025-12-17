# frozen_string_literal: true
#
# Copyright (C) 2017-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
class Member < Ygg::PublicModel

module Currency
  class Condition
    attr_reader :name
    attr_reader :deps
#    attr_reader :until
    attr_accessor :conds

    def initialize(name:, value:, to: nil)
      @name = name
      @value = value
      @deps = Set.new
      @until = (@value && to) ? to.call : nil
    end

    def value
      if @value.is_a?(Array)
        @value = evaluate_expression(@value)
      else
        @value
      end
    end

    def evaluate_operand(o)
      if o.is_a?(Array)
        evaluate_expression(o)
      elsif o.is_a?(TrueClass) || o.is_a?(FalseClass)
        o
      else
        cond = conds.conds[o]

        raise "Missing condition #{o}" if !cond

        @deps << o
        @until = [ @until, cond.until ].compact.min

        cond.value
      end
    end

    def evaluate_expression(e)

      res = nil
      ex = e.dup

      cur = evaluate_operand(ex.shift)
      until ex.empty? do
        op = ex.shift
        val = ex.shift

        # Evaluate operand anyway
        opnd = evaluate_operand(val)

        if op == :AND
          cur = cur && opnd
        elsif op == :OR
          cur = cur || opnd
        else
          raise "Unknown operator '#{op}'"
        end
      end

      cur
    end

    def deps
      value

      @deps
    end

    def until
      value
      @until
    end

    def to_s
      "#{name}=#{value}"
    end

    def inspect
      to_s
    end

    def as_json
     res = {
      value: value,
      until: self.until,
     }

     res[:deps] = deps.as_json if deps
     res
   end
  end

  class Conditions
    attr_reader :conds

    def initialize
      @conds = Hash.new
    end

    def <<(cond)
      cond.conds = self

      @conds[cond.name] = cond
    end

    def [](name)
      @conds[name]
    end

    def to_s
      'Conditions'
    end

    def inspect
      to_s
    end

    def as_json
      Hash[ @conds.map { |k,v| [ k, v.as_json ] } ]
    end

    def method_missing(name, *args)
      @conds[name]
    end
  end

  def compute_currency(time: Time.now)
    # TODO: Blocco volo
    # TODO: Esente CAV
    # TODO: TMG
    # TODO: FI
    # TODO: PPL

    conds = Conditions.new

    mship_ranges = RangeArray.new(memberships.map { |x| (x.valid_from.to_time)..(x.valid_to.to_time) })
    mship_franges = mship_ranges.flatten

    conds << Condition.new(
      name: :membership,
      value: mship_franges.any? { |x| x.include?(time) },
      to: lambda { mship_franges.select { |x| x.include?(time) }.map(&:end).max },
    )

    svcs = services.joins(:service_type)

    asses = svcs.where(service_type: { is_association: true })
    ass_ranges = RangeArray.new(asses.map { |x| (x.valid_from.to_time)..(x.valid_to.to_time) })
    ass_franges = ass_ranges.flatten

    conds << Condition.new(
      name: :ass,
      value: ass_franges.any? { |x| x.include?(time) },
      to: lambda { ass_franges.select { |x| x.include?(time) }.map(&:end).max },
    )

    cavs = svcs.where(service_type: { is_cav: true })
    cav_ranges = RangeArray.new(cavs.map { |x| (x.valid_from.to_time)..(x.valid_to.to_time) })
    cav_franges = cav_ranges.flatten

    conds << Condition.new(
      name: :cav,
      value: cav_franges.any? { |x| x.include?(time) },
      to: lambda { cav_franges.select { |x| x.include?(time) }.map(&:end).max },
    )


    caas = svcs.where(service_type: { symbol: 'CAA' })
    caa_ranges = RangeArray.new(caas.map { |x| (x.valid_from.to_time)..(x.valid_to.to_time) })
    caa_franges = caa_ranges.flatten

    conds << Condition.new(
      name: :caa,
      value: caa_franges.any? { |x| x.include?(time) },
      to: lambda { caa_franges.select { |x| x.include?(time) }.map(&:end).max },
    )

    caps = svcs.where(service_type: { symbol: 'CAP' })
    cap_ranges = RangeArray.new(caps.map { |x| (x.valid_from.to_time)..(x.valid_to.to_time) })
    cap_franges = cap_ranges.flatten

    conds << Condition.new(
      name: :cap,
      value: cap_franges.any? { |x| x.include?(time) },
      to: lambda { cap_franges.select { |x| x.include?(time) }.map(&:end).max },
    )

    our_medicals = medicals.where(type: [ 'IT class 2', 'IT class 1', 'LAPL' ])

    conds << Condition.new(
      name: :medical,
      value: our_medicals.any?,
      to: lambda { our_medicals.map(&:valid_to).max },
    )

    # SFCL.160(a)(1) specifies that hours/launches have 24 month window
    # AMC1 SFCL.160(a)(1)(ii) specifies that FI training flights have a 24 month window from the last day of the month in which
    #   the flight has been performed.
    #
    # Thus we retrieve all the flights from now to the beginning of the 24th month before current. Then we apply the specific criteria

    calendar_24_month_window = (time - 24.months).beginning_of_day
    currency_months_start_from = (time - 24.months).beginning_of_month
    ninety_days_window = (time - 90.days).beginning_of_day

    # Select all the relevant flights
    pic_or_dual_flights_in_enlarged_24_months =
      flights.where('takeoff_time > ?', currency_months_start_from).
              where(pilot1_role: [ 'PIC', 'PICUS', 'FI_PIC', 'DUAL', 'FI', 'FE' ]).
              order(takeoff_time: 'DESC')

    # Compute specific selections
    pic_or_dual_flights_in_24_months =
      pic_or_dual_flights_in_enlarged_24_months.select { |x|
        x.takeoff_time > calendar_24_month_window &&
        x.takeoff_time < time
      }

    pic_or_dual_gld_flights_in_enlarged_24_months =
      pic_or_dual_flights_in_enlarged_24_months.select { |x| x.aircraft_class == 'GLD' }

    pic_or_dual_gld_flights_in_24_months =
      pic_or_dual_gld_flights_in_enlarged_24_months.select { |x|
        x.takeoff_time > calendar_24_month_window &&
        x.takeoff_time < time
      }

    pic_or_dual_tmg_flights_in_24_months =
      pic_or_dual_flights_in_enlarged_24_months.select { |x| x.aircraft_class == 'TMG' }

    pic_or_dual_gld_flights_in_90_days = pic_or_dual_gld_flights_in_enlarged_24_months.
      select { |x|
        ([ 'PIC', 'PICUS', 'DUAL', 'FI_PIC', 'FI', 'FE' ].include?(x.pilot1_role)) &&
        x.takeoff_time > ninety_days_window &&
        x.takeoff_time < time
      }

    pic_or_dual_tmg_flights_in_90_days = pic_or_dual_tmg_flights_in_24_months.
      select { |x|
        ([ 'PIC', 'PICUS', 'DUAL', 'FI_PIC', 'FI', 'FE' ].include?(x.pilot1_role)) &&
        x.takeoff_time > ninety_days_window &&
        x.takeoff_time < time
      }

    # Some stats
    gld_hours_in_24_months = pic_or_dual_gld_flights_in_24_months.sum { |x| x.landing_time - x.takeoff_time }
    gld_launches_in_24_months = pic_or_dual_gld_flights_in_24_months.count

    tmg_hours_in_24_months = pic_or_dual_tmg_flights_in_24_months.sum { |x| x.landing_time - x.takeoff_time }
    tmg_launches_in_24_months = pic_or_dual_tmg_flights_in_24_months.count

    gld_hours_in_90_days = pic_or_dual_gld_flights_in_90_days.sum { |x| x.landing_time - x.takeoff_time }
    gld_launches_in_90_days = pic_or_dual_gld_flights_in_90_days.count

    tmg_hours_in_90_days = pic_or_dual_tmg_flights_in_90_days.sum { |x| x.landing_time - x.takeoff_time }
    tmg_launches_in_90_days = pic_or_dual_tmg_flights_in_90_days.count

    # SFCL.160(a)
    flights_amounting_5_gld_hours_in_24_months = []
    sum = 0
    pic_or_dual_gld_flights_in_24_months.each do |flight|
      if sum < 5.hours
        sum += flight.landing_time - flight.takeoff_time
        flights_amounting_5_gld_hours_in_24_months << flight
      else
        break
      end
    end

    conds << Condition.new(
      name: :five_gld_hours_in_24_months,
      value: gld_hours_in_24_months >= 5.hours,
      to: lambda { flights_amounting_5_gld_hours_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(b)(1)
    flights_amounting_6_tmg_hours_in_24_months = []
    sum = 0
    pic_or_dual_tmg_flights_in_24_months.each do |flight|
      if sum < 6.hours
        sum += flight.landing_time - flight.takeoff_time
        flights_amounting_6_tmg_hours_in_24_months << flight
      else
        break
      end
    end

    conds << Condition.new(
      name: :six_tmg_hours_in_24_months,
      value: tmg_hours_in_24_months >= 6.hours,
      to: lambda { flights_amounting_6_tmg_hours_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(b)
    flights_amounting_12_gld_or_tmg_hours_in_24_months = []
    sum = 0
    pic_or_dual_flights_in_24_months.each do |flight|
      if sum < 12.hours
        sum += flight.landing_time - flight.takeoff_time
        flights_amounting_12_gld_or_tmg_hours_in_24_months << flight
      else
        break
      end
    end

    conds << Condition.new(
      name: :twelve_gld_or_tmg_hours_in_24_months,
      value: (gld_hours_in_24_months + tmg_hours_in_24_months) >= 6.hours,
      to: lambda { flights_amounting_12_gld_or_tmg_hours_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(a)(1)(i)
    conds << Condition.new(
      name: :fifteen_gld_launches_in_24_months,
      value: pic_or_dual_gld_flights_in_24_months.count >= 15,
      to: lambda { pic_or_dual_gld_flights_in_24_months.first(15).last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(a)(2)(ii)
    conds << Condition.new(
      name: :twelve_tmg_launches_in_24_months,
      value:  pic_or_dual_tmg_flights_in_24_months.count >= 12,
      to: lambda { pic_or_dual_tmg_flights_in_24_months.first(12).last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(a)(1)(ii) + AMC1 SFCL.160(a)(1)(ii)(d) (d)
    last_2_gld_training_flights_in_24_months =
      pic_or_dual_gld_flights_in_enlarged_24_months.select { |x| x.purpose == 'TRAINING' }.first(2)

    conds << Condition.new(
      name: :two_gld_training_flights_in_24_months,
      value: last_2_gld_training_flights_in_24_months.count >= 2,
      to: lambda { last_2_gld_training_flights_in_24_months.last.takeoff_time.getlocal.end_of_month + 24.months },
    )

    # SFCL.160(b)(1)(iii)
    last_tmg_training_flights_in_24_months =
      pic_or_dual_tmg_flights_in_24_months.select { |x|
        x.purpose == 'TRAINING' && (x.landing_time - x.takeoff_time) >= 1.hour
      }.first

    conds << Condition.new(
      name: :one_tmg_training_flight_in_24_months,
      value: !!last_tmg_training_flights_in_24_months,
      to: lambda { last_tmg_training_flights_in_24_months.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(a)(2)
    last_gld_proficiency_flight_in_24_months = pic_or_dual_gld_flights_in_24_months.
      select { |x| x.purpose == 'PROFICIENCY_CHECK' }.last

    conds << Condition.new(
      name: :one_gld_proficiency_flight_in_24_months,
      value: !!last_gld_proficiency_flight_in_24_months,
      to: lambda { last_gld_proficiency_flight_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(b)(2)
    last_tmg_proficiency_flight_in_24_months = pic_or_dual_tmg_flights_in_24_months.
      select { |x| x.purpose == 'PROFICIENCY_CHECK' }.last

    conds << Condition.new(
      name: :one_tmg_proficiency_flight_in_24_months,
      value: !!last_tmg_proficiency_flight_in_24_months,
      to: lambda { last_tmg_proficiency_flight_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.155(c)
    last_5_tows_in_24_months = pic_or_dual_gld_flights_in_24_months.select { |x| x.launch_type == 'TOW' }.first(5)

    conds << Condition.new(
      name: :five_tows_in_24_months,
      value: last_5_tows_in_24_months.count >= 5,
      to: lambda { last_5_tows_in_24_months.last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    last_5_winches_in_24_months = pic_or_dual_gld_flights_in_24_months.select { |x| x.launch_type == 'WINCH' }.first(15)

    conds << Condition.new(
      name: :five_winches_in_24_months,
      value: last_5_winches_in_24_months.count >= 5,
      to: lambda { last_5_winches_in_24_months.first(5).last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    last_5_sl_in_24_months = pic_or_dual_gld_flights_in_24_months.select { |x| x.launch_type == 'SL' }.first(5)

    conds << Condition.new(
      name: :five_sl_in_24_months,
      value: last_5_sl_in_24_months.count >= 5,
      to: lambda { last_5_sl_in_24_months.first(5).last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    pic_or_dual_sl_or_tmg_flights_in_24_months =
      pic_or_dual_flights_in_24_months.select { |x|
        (x.aircraft_class == 'GLD' && x.launch_type == 'SL') ||
        x.aircraft_class == 'TMG'
      }

    last_5_sl_or_tmg_in_24_months = pic_or_dual_sl_or_tmg_flights_in_24_months.first(5)

    conds << Condition.new(
      name: :five_sl_or_tmg_in_24_months,
      value: last_5_sl_or_tmg_in_24_months.count >= 5,
      to: lambda { last_5_sl_or_tmg_in_24_months.first(5).last.takeoff_time.getlocal.end_of_day + 24.months },
    )

    # SFCL.160(e)(1)
    conds << Condition.new(
      name: :three_gld_launches_in_90_days,
      value: pic_or_dual_gld_flights_in_90_days.count >= 3,
      to: lambda { pic_or_dual_gld_flights_in_90_days.first(3).last.takeoff_time.getlocal.end_of_day + 90.days },
    )

    # SFCL.160(e)(2)
    conds << Condition.new(
      name: :three_tmg_launches_in_90_days,
      value:  pic_or_dual_tmg_flights_in_90_days.count >= 3,
      to: lambda { pic_or_dual_tmg_flights_in_90_days.first(3).last.takeoff_time.getlocal.end_of_day + 90.days },
    )

    # Recency club
    flights_in_90_days = pic_or_dual_flights_in_24_months.
      select { |x|
        x.takeoff_time > ninety_days_window &&
        x.takeoff_time < time
      }

    conds << Condition.new(
      name: :acao_recency,
      value: flights_in_90_days.count >= 1,
      to: lambda { flights_in_90_days.first(3).first.takeoff_time.getlocal.end_of_day + 90.days },
    )

    # SFCL.115(a)(2)(ii)(A)
    pic_flights = pic_or_dual_gld_flights_in_enlarged_24_months.
                  select { |x| [ 'PIC', 'PICUS', 'FI_PIC' ].include?(x.pilot1_role) }

    pic_hours = pic_flights.sum { |x| x.landing_time - x.takeoff_time }

    ten_hours_as_pic = if pic_hours >= 10.hours
      true
    else
      total_time_as_pic = flights.where(aircraft_class: 'GLD').
                                  where(pilot1_role: [ 'PIC', 'PICUS','FI_PIC' ]).
                                  sum('landing_time - takeoff_time')

      total_time_as_pic >= 10.hours
    end

    conds << Condition.new(
      name: :ten_hours_as_pic,
      value: ten_hours_as_pic,
    )

    # SFCL.115(a)(2)(ii)(A)
    thirty_launches_as_pic = if pic_flights.count >= 30
      true
    else
      launches_as_pic = flights.where(aircraft_class: 'GLD').
                                where(pilot1_role: [ 'PIC', 'PICUS', 'FI_PIC' ]).
                                count

      launches_as_pic >= 30
    end

    conds << Condition.new(
      name: :thirty_launches_as_pic,
      value: thirty_launches_as_pic,
    )

    spl_licenses = licenses.select { |x| x.type == 'SPL' }

    conds << Condition.new(
      name: :spl_license,
      value: spl_licenses.any? { |x| time < x.valid_to },
      to: lambda { spl_licenses.map(&:valid_to).max },
    )

    ppl_licenses = licenses.select { |x| x.type == 'PPL' }

    conds << Condition.new(
      name: :ppl_license,
      value: ppl_licenses.any? { |x| time < x.valid_to },
      to: lambda { ppl_licenses.map(&:valid_to).max },
    )

    # SFCL.115(a)(2)(ii)(A)
    pax_endorsment =
      spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'PAX' }
      }

    conds << Condition.new(
      name: :pax_endorsment,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'PAX' }
      },
    )

    # SFCL.115(a)(2)(ii)(B)
    fi_rating =
      spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'FI' }
      }

    conds << Condition.new(
      name: :fi_rating,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'FI' }
      },
    )

    # SFCL.155(c)
    conds << Condition.new(
      name: :tow_launch_endorsment,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'TOW_LAUNCH' }
      },
    )

    # SFCL.155(c)
    conds << Condition.new(
      name: :sl_launch_endorsment,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'SLSS' }
      },
    )

    # SFCL.155(c)
    conds << Condition.new(
      name: :winch_launch_endorsment,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'WINCH' }
      },
    )

    # SFCL.
    conds << Condition.new(
      name: :tmg_endorsment,
      value: spl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'TMG' }
      },
    )

    # SFCL.160(c)
    conds << Condition.new(
      name: :ppl_tmg_endorsment,
      value:  ppl_licenses.any? { |license|
        license.ratings.any? { |rating| rating.rating_type.symbol == 'TMG' }
      },
    )


    # Derived statuses ----------------------------------------

    # SFCL.160(a)
    conds << Condition.new(
      name: :gld_current,
      value: [ [ :five_gld_hours_in_24_months, :AND, :fifteen_gld_launches_in_24_months, :AND,
                 :two_gld_training_flights_in_24_months, ], :OR, :one_gld_proficiency_flight_in_24_months ],
    )

    # SFCL.160(b)
    # I suppose PPL currency should be checked if ppl_tmg_endorsment
    conds << Condition.new(
      name: :tmg_current,
      value: [
        :ppl_tmg_endorsment, :OR, [
          :tmg_endorsment, :AND, [
            :twelve_gld_or_tmg_hours_in_24_months, :AND,
            :six_tmg_hours_in_24_months, :AND,
            :twelve_tmg_launches_in_24_months, :AND,
            :one_tmg_training_flight_in_24_months,
          ], :OR, :one_tmg_proficiency_flight_in_24_months
        ]
      ],
    )

    # SFCL.115(a)(2) + SFCL.160(e)(1)
    conds << Condition.new(
      name: :gld_pax_current,
      value: [
        :fi_rating, :OR, [
          [ :ten_hours_as_pic, :OR, :thirty_launches_as_pic ], :AND,
          :pax_endorsment
        ], :AND, :three_gld_launches_in_90_days,
      ],
    )

    # SFCL.115(a)(2) + SFCL.160(e)(2)
    conds << Condition.new(
      name: :tmg_pax_current,
      value: [
        :fi_rating, :OR, [
          [ :ten_hours_as_pic, :OR, :thirty_launches_as_pic ], :AND,
          :pax_endorsment
        ], :AND, :three_tmg_launches_in_90_days,
      ],
    )

    # SFCL.155(a)
    # SFCL.155(c)
    conds << Condition.new(
      name: :tow_current,
      value: [ :tow_launch_endorsment, :AND, :five_tows_in_24_months ],
    )

    conds << Condition.new(
      name: :sl_current,
      value: [ :sl_launch_endorsment, :AND, :five_sl_or_tmg_in_24_months ],
    )

    conds << Condition.new(
      name: :winch_current,
      value: [ :winch_launch_endorsment, :AND, :five_winches_in_24_months ],
    )

    # Build final matrix ---------------------------------------------------------






    conds << Condition.new(
      name: :gld_tow_private_solo,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND, :tow_current,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_private_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :tow_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_private_pax,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :tow_launch_endorsment, :AND, :tow_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_private_student,
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    conds << Condition.new(
      name: :gld_tow_club_solo,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :tow_launch_endorsment, :AND, :tow_current,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_club_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :tow_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_club_pax,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :tow_launch_endorsment, :AND,
        :tow_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_tow_club_student,
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    # Aggiungere volo per conseguimento TOW avendo già SPL?
    conds << Condition.new(
      name: :gld_sl_private_solo,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :sl_launch_endorsment, :AND, :sl_current,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_private_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :sl_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_private_pax,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :sl_launch_endorsment, :AND, :sl_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_private_student,
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    conds << Condition.new(
      name: :gld_sl_club_solo,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :sl_launch_endorsment, :AND,
        :sl_current,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_club_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :sl_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_club_pax,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND,  :spl_license, :AND, :gld_current, :AND, :sl_launch_endorsment, :AND,
        :sl_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_sl_club_student, # Verificare che serva CAA/CAP per gli allievi
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    # Aggiungere volo per conseguimento SL avendo già SPL?
    conds << Condition.new(
      name: :gld_winch_private_solo,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND, 
        :winch_launch_endorsment, :AND, :winch_current,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_private_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :winch_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_private_pax,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :gld_current, :AND,
        :winch_launch_endorsment, :AND, :winch_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_private_student,
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    conds << Condition.new(
      name: :gld_winch_club_solo,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :winch_launch_endorsment, :AND, :winch_current,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_club_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :winch_launch_endorsment,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_club_pax,
      value: [
        :membership, :AND, :cav, :AND, [ :caa, :OR, :cap ], :AND, :acao_recency, :AND,
        :medical, :AND, :spl_license, :AND, :gld_current, :AND, :winch_launch_endorsment, :AND,
        :winch_current, :AND, :gld_pax_current,
      ],
    )

    conds << Condition.new(
      name: :gld_winch_club_student, # Verificare che serva CAA/CAP per gli allievi
      value: [ :membership, :AND, :cav, :AND, :medical, ],
    )

    # Aggiungere volo per conseguimento WINCH avendo già SPL?
    conds << Condition.new(
      name: :tmg_private_solo,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :tmg_endorsment, :AND, :tmg_current,
      ],
    )

    conds << Condition.new(
      name: :tmg_private_solo_picus,
      value: [ :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :tmg_endorsment, ],
    )

    conds << Condition.new(
      name: :tmg_private_pax,
      value: [
        :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, :AND, :tmg_endorsment, :AND,
        :tmg_current, :AND, :tmg_pax_current,
      ],
    )

    conds << Condition.new(
      name: :tmg_private_student,
      value: [ :membership, :AND, :cav, :AND, :medical, :AND, :spl_license ],
    )

    conds << Condition.new(
      name: :tmg_club_solo,
      value: [
        :membership, :AND, :cav, :AND, :acao_recency, :AND, :medical, :AND, :spl_license, :AND,
        :spl_license, :AND, :tmg_endorsment, :AND, :tmg_current,
      ],
    )

    conds << Condition.new(
      name: :tmg_club_solo_picus,
      value: [
        :membership, :AND, :cav, :AND, :acao_recency, :AND, :medical, :AND, :spl_license, :AND,
        :spl_license, :AND, :tmg_endorsment,
      ],
    )

    conds << Condition.new(
      name: :tmg_club_pax,
      value: [
        :membership, :AND, :cav, :AND, :acao_recency, :AND, :medical, :AND, :spl_license, :AND,
        :tmg_endorsment, :AND, :tmg_current, :AND, :tmg_pax_current,
      ],
    )

    conds << Condition.new(
      name: :tmg_club_student,
      value: [ :membership, :AND, :cav, :AND, :medical, :AND, :spl_license, ],
    )

    conds_json = conds.as_json

    matrix_conds = [
      :gld_tow_private_solo,
      :gld_tow_private_solo_picus,
      :gld_tow_private_pax,
      :gld_tow_private_student,
      :gld_tow_club_solo,
      :gld_tow_club_solo_picus,
      :gld_tow_club_pax,
      :gld_tow_club_student,
      :gld_sl_private_solo,
      :gld_sl_private_solo_picus,
      :gld_sl_private_pax,
      :gld_sl_private_student,
      :gld_sl_club_solo,
      :gld_sl_club_solo_picus,
      :gld_sl_club_pax,
      :gld_sl_club_student,
      :gld_winch_private_solo,
      :gld_winch_private_solo_picus,
      :gld_winch_private_pax,
      :gld_winch_private_student,
      :gld_winch_club_solo,
      :gld_winch_club_solo_picus,
      :gld_winch_club_pax,
      :gld_winch_club_student,
      :tmg_private_solo,
      :tmg_private_solo_picus,
      :tmg_private_pax,
      :tmg_private_student,
      :tmg_club_solo,
      :tmg_club_solo_picus,
      :tmg_club_pax,
      :tmg_club_student,
    ]

    currency = {
      gld_launches_in_24_months: gld_launches_in_24_months,
      gld_hours_in_24_months: gld_hours_in_24_months,
      tmg_launches_in_24_months: tmg_launches_in_24_months,
      tmg_hours_in_24_months: tmg_hours_in_24_months,
      gld_launches_in_90_days: gld_launches_in_90_days,
      gld_hours_in_90_days: gld_hours_in_90_days,
      tmg_launches_in_90_days: tmg_launches_in_90_days,
      tmg_hours_in_90_days: tmg_hours_in_90_days,
      conds: conds_json,
      matrix_conds: matrix_conds,
    }

    currency
  end

end

end
end
end
