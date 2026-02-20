# frozen_string_literal: true
#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'open-uri'

module Ygg
module Acao

class MeteoEntry < Ygg::PublicModel
  self.table_name = 'acao.meteo_entries'

  require 'tzinfo'

  def self.update
    url = Rails.application.config.acao.openmeteo_url +
             "?latitude=45.8206&longitude=8.8251" +
               "&hourly=temperature_2m,dew_point_2m,relative_humidity_2m,pressure_msl,surface_pressure,wind_speed_10m," +
                 "wind_gusts_10m,wind_speed_900hPa,wind_speed_800hPa,wind_speed_700hPa" +
               "&timezone=Europe%2FBerlin&forecast_days=1"

    res = JSON.parse(URI.open(url, 'r').read, symbolize_names: true)

    temperature_2m_max_fc = nil
    humidity_2m_max_fc = nil
    dew_point_2m_max_fc = nil
    wind_speed_10m_max_fc = nil
    wind_gusts_10m_max_fc = nil
    wind_speed_900hpa_max_fc = nil
    wind_speed_800hpa_max_fc = nil
    wind_speed_700hpa_max_fc = nil
    relative_humidity_2m_max_fc = nil
    pressure_msl_min_fc = nil
    surface_pressure_min_fc = nil
    pressure_altitude_max_fc = nil
    density_altitude_max_fc = nil

    transaction do
      self.where(at: Time.new.beginning_of_day..Time.new.end_of_day).delete_all

      res[:hourly][:time].each_with_index do |at,index|
        h = res[:hourly]

        rec = new(
          at: Time.parse(at),
          pressure_msl: h[:pressure_msl][index],
          surface_pressure: h[:surface_pressure][index],
          temperature_2m: h[:temperature_2m][index],
          relative_humidity_2m: h[:relative_humidity_2m][index],
          dew_point_2m: h[:dew_point_2m][index],
          wind_speed_10m: h[:wind_speed_10m][index],
          wind_gusts_10m: h[:wind_gusts_10m][index],
          wind_speed_900hpa: h[:wind_speed_900hPa][index],
          wind_speed_800hpa: h[:wind_speed_800hPa][index],
          wind_speed_700hpa: h[:wind_speed_700hPa][index],
        )

        alt = 243

        rec.pressure_altitude = Meteo.pressure_altitude(rec.pressure_msl * 100.0, alt)
        water_vapor_pp = Meteo.water_vapor_saturated_pressure(rec.dew_point_2m)
        dry_air_pp = (rec.surface_pressure * 100.0) - water_vapor_pp
        air_density = Meteo.wet_air_density(rec.temperature_2m, dry_air_pp, water_vapor_pp)

        rec.density_altitude = Meteo.density_altitude(air_density)

        pressure_msl_min_fc = [ pressure_msl_min_fc, rec.pressure_msl ].compact.min
        surface_pressure_min_fc = [ surface_pressure_min_fc, rec.surface_pressure ].compact.min
        temperature_2m_max_fc = [ temperature_2m_max_fc, rec.temperature_2m ].compact.max
        dew_point_2m_max_fc = [ dew_point_2m_max_fc, rec.dew_point_2m ].compact.min
        relative_humidity_2m_max_fc = [ relative_humidity_2m_max_fc, rec.relative_humidity_2m ].compact.min
        wind_speed_10m_max_fc = [ wind_speed_10m_max_fc, rec.wind_speed_10m ].compact.max
        wind_gusts_10m_max_fc = [ wind_gusts_10m_max_fc, rec.wind_gusts_10m ].compact.max
        wind_speed_900hpa_max_fc = [ wind_speed_900hpa_max_fc, rec.wind_speed_900hpa ].compact.max
        wind_speed_800hpa_max_fc = [ wind_speed_800hpa_max_fc, rec.wind_speed_800hpa ].compact.max
        wind_speed_700hpa_max_fc = [ wind_speed_700hpa_max_fc, rec.wind_speed_700hpa ].compact.max
        pressure_altitude_max_fc = [ pressure_altitude_max_fc, rec.pressure_altitude ].compact.max
        density_altitude_max_fc = [ density_altitude_max_fc, rec.density_altitude ].compact.max

        rec.save!
      end
    end

    day = Ygg::Acao::Day.find_or_initialize_by(date: Date.today) do |day|
      day.wind_day = wind_speed_10m_max_fc > 15 || wind_speed_900hpa_max_fc > 25
    end

    day.update(
      pressure_msl_min_fc: pressure_msl_min_fc,
      surface_pressure_min_fc: surface_pressure_min_fc,
      temperature_2m_max_fc: temperature_2m_max_fc,
      dew_point_2m_max_fc: dew_point_2m_max_fc,
      relative_humidity_2m_max_fc: relative_humidity_2m_max_fc,
      wind_speed_10m_max_fc: wind_speed_10m_max_fc,
      wind_gusts_10m_max_fc: wind_gusts_10m_max_fc,
      wind_speed_900hpa_max_fc: wind_speed_900hpa_max_fc,
      wind_speed_800hpa_max_fc: wind_speed_800hpa_max_fc,
      wind_speed_700hpa_max_fc: wind_speed_700hpa_max_fc,
      pressure_altitude_max_fc: pressure_altitude_max_fc,
      density_altitude_max_fc: density_altitude_max_fc,
    )
  end


  module Meteo
    def self.geopotential_height(h)
      (6356766 * h) / (6356766 + h)
    end

    def self.geometric_height(h)
      (6356766 * h) / (6356766 - h)
    end

    def self.qfe_to_qnh(qfe, h)
      qfe * (1 + ((h * 0.0065) / 288.15) * ((101325 / qfe)**((287.058 * 0.0065) / 9.81)))**(9.81 / (287.058 * 0.0065))
    end

    def self.qnh_to_qfe(qnh, h)
      (((qnh / 100) ** 0.190263) - (8.417286E-5 * h)) ** (1 / 0.190263) * 100
    end

    # Given an atmospheric pressure measurement, the pressure altitude is the imputed altitude that the
    # International Standard Atmosphere model predicts to have the same pressure as the observed value
    #
    # p: measured pressure in Pa
    # h: altitude
    #
    def self.pressure_altitude(p, h)
      h + 44307.69 * (1 - (p / 101325)**(((287.058 * 0.0065) / 9.81)))
    end

    def self.water_vapor_saturated_pressure(t)
      610.78 / (0.99999683 + t * (-0.90826951E-02 + t * (0.78736169E-04 + t * (-0.61117958E-06 +
               t * (0.43884187E-08 + t * (-0.29883885E-10 + t * (0.21874425E-12 + t * (-0.17892321E-14 +
               t * (0.11112018E-16 + t * -0.30994571E-19)))))))))**8
    end

  #  def self.water_vapor_saturated_pressure(t)
  #    611.21 * Math::E ** ((18.678 - (t/234.5))*(t / (257.14 + t)))
  #  end
  #
  #  def self.water_vapor_saturated_pressure(t)
  #    610.78 * Math::E ** ((t * 17.27) / (t + 237.3))
  #  end

    # Wet air density
    # t: temperature in °C
    # dry_pp: partial pressure of dry air in Pa
    # water_pp: partial pressure of water vapor in Pa
    #
    def self.wet_air_density(t, dry_pp, water_pp)
      (dry_pp / (287.058 * (t + 273.15))) +
      (water_pp / (461.495 * (t + 273.15)))
    end

    def self.density_altitude(rho)
      geometric_height((288.15 / 0.0065) * (1 - ((8.31432 * 288.15 * rho) / (0.028964 * 101325)) **
                           ((0.0065 * 8.31432) / ((9.80665 * 0.028964) - (0.0065 * 8.31432) ))))
    end
  end

end

end
end
