class AcaoSchema < ActiveRecord::Migration[6.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.create_schema 'acao'
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    execute "ALTER TABLE acao_aircraft_types SET SCHEMA acao"
    execute 'ALTER TABLE acao_aircraft_types DROP CONSTRAINT acao_aircraft_types_pkey CASCADE'
    rename_table 'acao_aircraft_types', 'aircraft_types'
    execute 'ALTER TABLE acao.aircraft_types ADD CONSTRAINT aircraft_types_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_aircrafts SET SCHEMA acao"
    execute 'ALTER TABLE acao_aircrafts DROP CONSTRAINT acao_aircrafts_pkey CASCADE'
    rename_table 'acao_aircrafts', 'aircrafts'
    execute 'ALTER TABLE acao.aircrafts ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_airfields SET SCHEMA acao"
    execute 'ALTER TABLE acao_airfields DROP CONSTRAINT acao_airfields_pkey CASCADE'
    rename_table 'acao_airfields', 'airfields'
    execute 'ALTER TABLE acao.airfields ADD CONSTRAINT airfields_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_bar_menu_entries SET SCHEMA acao"
    execute 'ALTER TABLE acao_bar_menu_entries DROP CONSTRAINT acao_bar_menu_entries_pkey CASCADE'
    rename_table 'acao_bar_menu_entries', 'bar_menu_entries'
    execute 'ALTER TABLE acao.bar_menu_entries ADD CONSTRAINT bar_menu_entries_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_bar_transactions SET SCHEMA acao"
    execute 'ALTER TABLE acao_bar_transactions DROP CONSTRAINT acao_bar_transactions_pkey CASCADE'
    rename_table 'acao_bar_transactions', 'bar_transactions'
    execute 'ALTER TABLE acao.bar_transactions ADD CONSTRAINT bar_transactions_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_clubs SET SCHEMA acao"
    execute 'ALTER TABLE acao_clubs DROP CONSTRAINT acao_clubs_pkey CASCADE'
    rename_table 'acao_clubs', 'clubs'
    execute 'ALTER TABLE acao.clubs ADD CONSTRAINT clubs_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_fai_cards SET SCHEMA acao"
    execute 'ALTER TABLE acao_fai_cards DROP CONSTRAINT acao_fai_cards_pkey CASCADE'
    rename_table 'acao_fai_cards', 'fai_cards'
    execute 'ALTER TABLE acao.fai_cards ADD CONSTRAINT fai_cards_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_flights SET SCHEMA acao"
    execute 'ALTER TABLE acao_flights DROP CONSTRAINT acao_flights_pkey CASCADE'
    rename_table 'acao_flights', 'flights'
    execute 'ALTER TABLE acao.flights ADD CONSTRAINT flights_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_gates SET SCHEMA acao"
    execute 'ALTER TABLE acao_gates DROP CONSTRAINT acao_gates_pkey CASCADE'
    rename_table 'acao_gates', 'gates'
    execute 'ALTER TABLE acao.gates ADD CONSTRAINT gates_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_invoice_details SET SCHEMA acao"
    execute 'ALTER TABLE acao_invoice_details DROP CONSTRAINT acao_invoice_details_pkey CASCADE'
    rename_table 'acao_invoice_details', 'invoice_details'
    execute 'ALTER TABLE acao.invoice_details ADD CONSTRAINT invoice_details_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_invoices SET SCHEMA acao"
    execute 'ALTER TABLE acao_invoices DROP CONSTRAINT acao_invoices_pkey CASCADE'
    rename_table 'acao_invoices', 'invoices'
    execute 'ALTER TABLE acao.invoices ADD CONSTRAINT invoices_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_key_fobs SET SCHEMA acao"
    execute 'ALTER TABLE acao_key_fobs DROP CONSTRAINT acao_key_fobs_pkey CASCADE'
    rename_table 'acao_key_fobs', 'key_fobs'
    execute 'ALTER TABLE acao.key_fobs ADD CONSTRAINT key_fobs_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_license_ratings SET SCHEMA acao"
    execute 'ALTER TABLE acao_license_ratings DROP CONSTRAINT acao_license_ratings_pkey CASCADE'
    rename_table 'acao_license_ratings', 'license_ratings'
    execute 'ALTER TABLE acao.license_ratings ADD CONSTRAINT license_ratings_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_licenses SET SCHEMA acao"
    execute 'ALTER TABLE acao_licenses DROP CONSTRAINT acao_licenses_pkey CASCADE'
    rename_table 'acao_licenses', 'licenses'
    execute 'ALTER TABLE acao.licenses ADD CONSTRAINT licenses_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_medicals SET SCHEMA acao"
    execute 'ALTER TABLE acao_medicals DROP CONSTRAINT acao_medicals_pkey CASCADE'
    rename_table 'acao_medicals', 'medicals'
    execute 'ALTER TABLE acao.medicals ADD CONSTRAINT medicals_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_member_services SET SCHEMA acao"
    execute 'ALTER TABLE acao_member_services DROP CONSTRAINT acao_person_services_pkey CASCADE'
    rename_table 'acao_member_services', 'member_services'
    execute 'ALTER TABLE acao.member_services ADD CONSTRAINT member_services_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_memberships SET SCHEMA acao"
    execute 'ALTER TABLE acao_memberships DROP CONSTRAINT acao_memberships_pkey CASCADE'
    rename_table 'acao_memberships', 'memberships'
    execute 'ALTER TABLE acao.memberships ADD CONSTRAINT memberships_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_meter_buses SET SCHEMA acao"
    execute 'ALTER TABLE acao_meter_buses DROP CONSTRAINT acao_meter_buses_pkey CASCADE'
    rename_table 'acao_meter_buses', 'meter_buses'
    execute 'ALTER TABLE acao.meter_buses ADD CONSTRAINT meter_buses_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_meter_measures SET SCHEMA acao"
    execute 'ALTER TABLE acao_meter_measures DROP CONSTRAINT acao_meter_measures_pkey CASCADE'
    rename_table 'acao_meter_measures', 'meter_measures'
    execute 'ALTER TABLE acao.meter_measures ADD CONSTRAINT meter_measures_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_meters SET SCHEMA acao"
    execute 'ALTER TABLE acao_meters DROP CONSTRAINT acao_meters_pkey CASCADE'
    rename_table 'acao_meters', 'meters'
    execute 'ALTER TABLE acao.meters ADD CONSTRAINT meters_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_payment_satispay_charges SET SCHEMA acao"
    execute 'ALTER TABLE acao_payment_satispay_charges DROP CONSTRAINT acao_payment_satispay_charges_pkey CASCADE'
    rename_table 'acao_payment_satispay_charges', 'payment_satispay_charges'
    execute 'ALTER TABLE acao.payment_satispay_charges ADD CONSTRAINT payment_satispay_charges_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_payment_services SET SCHEMA acao"
    execute 'ALTER TABLE acao_payment_services DROP CONSTRAINT acao_payment_services_pkey CASCADE'
    rename_table 'acao_payment_services', 'payment_services'
    execute 'ALTER TABLE acao.payment_services ADD CONSTRAINT payment_services_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_payments SET SCHEMA acao"
    execute 'ALTER TABLE acao_payments DROP CONSTRAINT acao_payments_pkey CASCADE'
    rename_table 'acao_payments', 'payments'
    execute 'ALTER TABLE acao.payments ADD CONSTRAINT payments_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_pilots SET SCHEMA acao"
    execute 'ALTER TABLE acao_pilots DROP CONSTRAINT acao_pilots_pkey CASCADE'
    rename_table 'acao_pilots', 'pilots'
    execute 'ALTER TABLE acao.pilots ADD CONSTRAINT pilots_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_planes SET SCHEMA acao"
    execute 'ALTER TABLE acao_planes DROP CONSTRAINT planes_pkey CASCADE'
    rename_table 'acao_planes', 'planes'
    execute 'ALTER TABLE acao.planes ADD CONSTRAINT planes_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_radar_events SET SCHEMA acao"
    execute 'ALTER TABLE acao_radar_events DROP CONSTRAINT trk_events_pkey CASCADE'
    rename_table 'acao_radar_events', 'radar_events'
    execute 'ALTER TABLE acao.radar_events ADD CONSTRAINT radar_events_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_radar_points SET SCHEMA acao"
    rename_table 'acao_radar_points', 'radar_points'

    execute "ALTER TABLE acao_radar_raw_points SET SCHEMA acao"
    rename_table 'acao_radar_raw_points', 'radar_raw_points'

    execute "ALTER TABLE acao_roster_days SET SCHEMA acao"
    execute 'ALTER TABLE acao_roster_days DROP CONSTRAINT acao_roster_days_pkey CASCADE'
    rename_table 'acao_roster_days', 'roster_days'
    execute 'ALTER TABLE acao.roster_days ADD CONSTRAINT roster_days_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_roster_entries SET SCHEMA acao"
    execute 'ALTER TABLE acao_roster_entries DROP CONSTRAINT acao_roster_entries_pkey CASCADE'
    rename_table 'acao_roster_entries', 'roster_entries'
    execute 'ALTER TABLE acao.roster_entries ADD CONSTRAINT roster_entries_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_service_types SET SCHEMA acao"
    execute 'ALTER TABLE acao_service_types DROP CONSTRAINT acao_service_types_pkey CASCADE'
    rename_table 'acao_service_types', 'service_types'
    execute 'ALTER TABLE acao.service_types ADD CONSTRAINT service_types_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_timetable_entries SET SCHEMA acao"
    execute 'ALTER TABLE acao_timetable_entries DROP CONSTRAINT acao_timetable_entries_pkey CASCADE'
    rename_table 'acao_timetable_entries', 'timetable_entries'
    execute 'ALTER TABLE acao.timetable_entries ADD CONSTRAINT timetable_entries_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_token_transactions SET SCHEMA acao"
    execute 'ALTER TABLE acao_token_transactions DROP CONSTRAINT acao_token_transactions_pkey CASCADE'
    rename_table 'acao_token_transactions', 'token_transactions'
    execute 'ALTER TABLE acao.token_transactions ADD CONSTRAINT token_transactions_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_tow_roster_days SET SCHEMA acao"
    execute 'ALTER TABLE acao_tow_roster_days DROP CONSTRAINT acao_tow_roster_days_pkey CASCADE'
    rename_table 'acao_tow_roster_days', 'tow_roster_days'
    execute 'ALTER TABLE acao.tow_roster_days ADD CONSTRAINT tow_roster_days_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_tow_roster_entries SET SCHEMA acao"
    execute 'ALTER TABLE acao_tow_roster_entries DROP CONSTRAINT acao_tow_roster_entries_pkey CASCADE'
    rename_table 'acao_tow_roster_entries', 'tow_roster_entries'
    execute 'ALTER TABLE acao.tow_roster_entries ADD CONSTRAINT tow_roster_entries_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_tows SET SCHEMA acao"
    execute 'ALTER TABLE acao_tows DROP CONSTRAINT acao_tows_pkey CASCADE'
    rename_table 'acao_tows', 'tows'
    execute 'ALTER TABLE acao.tows ADD CONSTRAINT tows_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_trackers SET SCHEMA acao"
    execute 'ALTER TABLE acao_trackers DROP CONSTRAINT acao_trackers_pkey CASCADE'
    rename_table 'acao_trackers', 'trackers'
    execute 'ALTER TABLE acao.trackers ADD CONSTRAINT trackers_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_trailers SET SCHEMA acao"
    execute 'ALTER TABLE acao_trailers DROP CONSTRAINT acao_trailers_pkey CASCADE'
    rename_table 'acao_trailers', 'trailers'
    execute 'ALTER TABLE acao.trailers ADD CONSTRAINT trailers_pkey PRIMARY KEY (id)'

    execute "ALTER TABLE acao_years SET SCHEMA acao"
    execute 'ALTER TABLE acao_years DROP CONSTRAINT acao_years_pkey CASCADE'
    rename_table 'acao_years', 'years'
    execute 'ALTER TABLE acao.years ADD CONSTRAINT years_pkey PRIMARY KEY (id)'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
