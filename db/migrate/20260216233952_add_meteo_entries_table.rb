class AddMeteoEntriesTable < ActiveRecord::Migration[8.1]
  def change
    create_table 'acao.meteo_entries', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamp :at
      t.float :pressure_msl
      t.float :surface_pressure
      t.float :temperature_2m
      t.float :dew_point_2m
      t.float :relative_humidity_2m
      t.float :wind_speed_10m
      t.float :wind_gusts_10m
      t.float :wind_speed_900hpa
      t.float :wind_speed_800hpa
      t.float :wind_speed_700hpa
      t.float :pressure_altitude
      t.float :density_altitude
    end

    add_index 'acao.meteo_entries', [ :at ]


    create_table 'acao.days', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.date :date, null: false

      t.float :pressure_msl_min
      t.float :pressure_msl_min_fc
      t.float :surface_pressure_min
      t.float :surface_pressure_min_fc
      t.float :temperature_2m_max
      t.float :temperature_2m_max_fc
      t.float :dew_point_2m_max
      t.float :dew_point_2m_max_fc
      t.float :relative_humidity_2m_max
      t.float :relative_humidity_2m_max_fc
      t.float :wind_speed_10m_max
      t.float :wind_speed_10m_max_fc
      t.float :wind_gusts_10m_max
      t.float :wind_gusts_10m_max_fc
      t.float :wind_speed_900hpa_max_fc
      t.float :wind_speed_800hpa_max_fc
      t.float :wind_speed_700hpa_max_fc
      t.float :pressure_altitude_max
      t.float :pressure_altitude_max_fc
      t.float :density_altitude_max
      t.float :density_altitude_max_fc

      t.boolean :wind_day, null: false, default: false
    end

    add_index 'acao.days', [ :date ]
  end
end
