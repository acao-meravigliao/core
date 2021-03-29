class AcaoUuid < ActiveRecord::Migration[6.0]
  def up
#    drop_table 'acao_bar_transactions_acl'
#    drop_table 'acao_memberships_acl'
#    drop_table 'acao_payments_acl'
#    drop_table 'flights_acl'

    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    execute 'ALTER TABLE acao.aircraft_types DROP CONSTRAINT aircraft_types_pkey CASCADE'
    rename_column 'acao.aircraft_types', 'id', 'id_old'
    rename_column 'acao.aircraft_types', 'uuid', 'id'
    add_index 'acao.aircraft_types', :id_old
    execute 'ALTER TABLE acao.aircraft_types ADD CONSTRAINT aircraft_types_pkey PRIMARY KEY (id)'

#    execute 'ALTER TABLE acao.aircrafts DROP CONSTRAINT aircrafts_pkey CASCADE'
#    rename_column 'acao.aircrafts', 'id', 'id_old'
#    rename_column 'acao.aircrafts', 'uuid', 'id'
#    add_index 'acao.aircrafts', :id_old
#    execute 'ALTER TABLE acao.aircrafts ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.aircrafts', 'owner_id', 'core.people')
    fk_to_uuid('acao.aircrafts', 'aircraft_type_id', 'acao.aircraft_types')

    execute 'ALTER TABLE acao.airfields DROP CONSTRAINT airfields_pkey CASCADE'
    rename_column 'acao.airfields', 'id', 'id_old'
    rename_column 'acao.airfields', 'uuid', 'id'
    add_index 'acao.airfields', :id_old
    execute 'ALTER TABLE acao.airfields ADD CONSTRAINT airfields_pkey PRIMARY KEY (id)'

#    execute 'ALTER TABLE acao.bar_menu_entries DROP CONSTRAINT bar_menu_entries_pkey CASCADE'
#    rename_column 'acao.bar_menu_entries', 'id', 'id_old'
#    rename_column 'acao.bar_menu_entries', 'uuid', 'id'
#    add_index 'acao.bar_menu_entries', :id_old
#    execute 'ALTER TABLE acao.bar_menu_entries ADD CONSTRAINT bar_menu_entries_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.bar_transactions DROP CONSTRAINT bar_transactions_pkey CASCADE'
    rename_column 'acao.bar_transactions', 'id', 'id_old'
    rename_column 'acao.bar_transactions', 'uuid', 'id'
    add_index 'acao.bar_transactions', :id_old
    execute 'ALTER TABLE acao.bar_transactions ADD CONSTRAINT bar_transactions_pkey PRIMARY KEY (id)'

    fk_to_uuid('acao.bar_transactions', 'person_id', 'core.people')
    fk_to_uuid('acao.bar_transactions', 'session_id', 'core.sessions')

#    execute 'ALTER TABLE acao.clubs DROP CONSTRAINT clubs_pkey CASCADE'
#    rename_column 'acao.clubs', 'id', 'id_old'
#    rename_column 'acao.clubs', 'uuid', 'id'
#    add_index 'acao.clubs', :id_old
#    execute 'ALTER TABLE acao.clubs ADD CONSTRAINT clubs_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.clubs', 'airfield_id', 'acao.airfields')

#    execute 'ALTER TABLE acao.fai_cards DROP CONSTRAINT fai_cards_pkey CASCADE'
#    rename_column 'acao.fai_cards', 'id', 'id_old'
#    rename_column 'acao.fai_cards', 'uuid', 'id'
#    add_index 'acao.fai_cards', :id_old
#    execute 'ALTER TABLE acao.fai_cards ADD CONSTRAINT fai_cards_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.fai_cards', 'person_id', 'core.people')

    execute 'ALTER TABLE acao.flights DROP CONSTRAINT flights_pkey CASCADE'
    rename_column 'acao.flights', 'id', 'id_old'
    rename_column 'acao.flights', 'uuid', 'id'
    add_index 'acao.flights', :id_old
    execute 'ALTER TABLE acao.flights ADD CONSTRAINT flights_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.flights', 'pilot1_id', 'core.people')
    fk_to_uuid('acao.flights', 'pilot2_id', 'core.people')
    fk_to_uuid('acao.flights', 'takeoff_airfield_id', 'acao.airfields')
    fk_to_uuid('acao.flights', 'landing_airfield_id', 'acao.airfields')
    fk_to_uuid('acao.flights', 'takeoff_location_id', 'core.locations')
    fk_to_uuid('acao.flights', 'landing_location_id', 'core.locations')
    fk_to_uuid('acao.flights', 'towed_by_id', 'core.people')
    fk_to_uuid('acao.flights', 'tow_release_location_id', 'core.locations')
    fk_to_uuid('acao.flights', 'aircraft_owner_id', 'core.people')
    add_foreign_key 'acao.flights', 'acao.aircrafts', column: 'aircraft_id'

#    execute 'ALTER TABLE acao.gates DROP CONSTRAINT gates_pkey CASCADE'
#    rename_column 'acao.gates', 'id', 'id_old'
#    rename_column 'acao.gates', 'uuid', 'id'
#    add_index 'acao.gates', :id_old
#    execute 'ALTER TABLE acao.gates ADD CONSTRAINT gates_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.gates', 'agent_id', 'core.agents')

#    execute 'ALTER TABLE acao.key_fobs DROP CONSTRAINT key_fobs_pkey CASCADE'
#    rename_column 'acao.key_fobs', 'id', 'id_old'
#    rename_column 'acao.key_fobs', 'uuid', 'id'
#    add_index 'acao.key_fobs', :id_old
#    execute 'ALTER TABLE acao.key_fobs ADD CONSTRAINT key_fobs_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.key_fobs', 'person_id', 'core.people')

    execute 'ALTER TABLE acao.licenses DROP CONSTRAINT licenses_pkey CASCADE'
    rename_column 'acao.licenses', 'id', 'id_old'
    rename_column 'acao.licenses', 'uuid', 'id'
    add_index 'acao.licenses', :id_old
    execute 'ALTER TABLE acao.licenses ADD CONSTRAINT licenses_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.licenses', 'pilot_id', 'core.people')

    execute 'ALTER TABLE acao.license_ratings DROP CONSTRAINT license_ratings_pkey CASCADE'
    rename_column 'acao.license_ratings', 'id', 'id_old'
    rename_column 'acao.license_ratings', 'uuid', 'id'
    add_index 'acao.license_ratings', :id_old
    execute 'ALTER TABLE acao.license_ratings ADD CONSTRAINT license_ratings_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.license_ratings', 'license_id', 'acao.licenses')

    execute 'ALTER TABLE acao.medicals DROP CONSTRAINT medicals_pkey CASCADE'
    rename_column 'acao.medicals', 'id', 'id_old'
    rename_column 'acao.medicals', 'uuid', 'id'
    add_index 'acao.medicals', :id_old
    execute 'ALTER TABLE acao.medicals ADD CONSTRAINT medicals_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.medicals', 'pilot_id', 'core.people')

    execute 'ALTER TABLE acao.meter_buses DROP CONSTRAINT meter_buses_pkey CASCADE'
    rename_column 'acao.meter_buses', 'id', 'id_old'
    rename_column 'acao.meter_buses', 'uuid', 'id'
    add_index 'acao.meter_buses', :id_old
    execute 'ALTER TABLE acao.meter_buses ADD CONSTRAINT meter_buses_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.meters DROP CONSTRAINT meters_pkey CASCADE'
    rename_column 'acao.meters', 'id', 'id_old'
    rename_column 'acao.meters', 'uuid', 'id'
    add_index 'acao.meters', :id_old
    execute 'ALTER TABLE acao.meters ADD CONSTRAINT meters_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.meters', 'person_id', 'core.people')
    fk_to_uuid('acao.meters', 'bus_id', 'acao.meter_buses')

    execute 'ALTER TABLE acao.meter_measures DROP CONSTRAINT meter_measures_pkey CASCADE'
    rename_column 'acao.meter_measures', 'id', 'id_old'
    add_column 'acao.meter_measures', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'acao.meter_measures', :id_old
    execute 'ALTER TABLE acao.meter_measures ADD CONSTRAINT meter_measures_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.meter_measures', 'meter_id', 'acao.meters')

    execute 'ALTER TABLE acao.payments DROP CONSTRAINT payments_pkey CASCADE'
    rename_column 'acao.payments', 'id', 'id_old'
    rename_column 'acao.payments', 'uuid', 'id'
    add_index 'acao.payments', :id_old
    execute 'ALTER TABLE acao.payments ADD CONSTRAINT payments_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.payments', 'person_id', 'core.people')
    add_foreign_key 'acao.payments', 'acao.invoices', column: 'invoice_id'

    execute 'ALTER TABLE acao.payment_satispay_charges DROP CONSTRAINT payment_satispay_charges_pkey CASCADE'
    rename_column 'acao.payment_satispay_charges', 'id', 'id_old'
    rename_column 'acao.payment_satispay_charges', 'uuid', 'id'
    add_index 'acao.payment_satispay_charges', :id_old
    execute 'ALTER TABLE acao.payment_satispay_charges ADD CONSTRAINT payment_satispay_charges_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.payment_satispay_charges', 'payment_id', 'acao.payments')

    execute 'ALTER TABLE acao.pilots DROP CONSTRAINT pilots_pkey CASCADE'
    rename_column 'acao.pilots', 'id', 'id_old'
    rename_column 'acao.pilots', 'uuid', 'id'
    add_index 'acao.pilots', :id_old
    execute 'ALTER TABLE acao.pilots ADD CONSTRAINT pilots_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.planes DROP CONSTRAINT planes_pkey CASCADE'
    rename_column 'acao.planes', 'id', 'id_old'
    rename_column 'acao.planes', 'uuid', 'id'
    add_index 'acao.planes', :id_old
    execute 'ALTER TABLE acao.planes ADD CONSTRAINT planes_pkey PRIMARY KEY (id)'

#    execute 'ALTER TABLE acao.radar_events DROP CONSTRAINT trk_events_pkey CASCADE'
#    rename_column 'acao.radar_events', 'id', 'id_old'
#    rename_column 'acao.radar_events', 'uuid', 'id'
#    add_index 'acao.radar_events', :id_old
#    execute 'ALTER TABLE acao.radar_events ADD CONSTRAINT radar_events_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.roster_days DROP CONSTRAINT roster_days_pkey CASCADE'
    rename_column 'acao.roster_days', 'id', 'id_old'
    rename_column 'acao.roster_days', 'uuid', 'id'
    add_index 'acao.roster_days', :id_old
    execute 'ALTER TABLE acao.roster_days ADD CONSTRAINT roster_days_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.roster_entries DROP CONSTRAINT roster_entries_pkey CASCADE'
    rename_column 'acao.roster_entries', 'id', 'id_old'
    rename_column 'acao.roster_entries', 'uuid', 'id'
    add_index 'acao.roster_entries', :id_old
    execute 'ALTER TABLE acao.roster_entries ADD CONSTRAINT roster_entries_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.roster_entries', 'person_id', 'core.people')
    fk_to_uuid('acao.roster_entries', 'roster_day_id', 'acao.roster_days')

    execute 'ALTER TABLE acao.service_types DROP CONSTRAINT service_types_pkey CASCADE'
    rename_column 'acao.service_types', 'id', 'id_old'
    rename_column 'acao.service_types', 'uuid', 'id'
    add_index 'acao.service_types', :id_old
    execute 'ALTER TABLE acao.service_types ADD CONSTRAINT service_types_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.payment_services DROP CONSTRAINT payment_services_pkey CASCADE'
    rename_column 'acao.payment_services', 'id', 'id_old'
    rename_column 'acao.payment_services', 'uuid', 'id'
    add_index 'acao.payment_services', :id_old
    execute 'ALTER TABLE acao.payment_services ADD CONSTRAINT payment_services_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.payment_services', 'payment_id', 'acao.payments')
    fk_to_uuid('acao.payment_services', 'service_type_id', 'acao.service_types')

    execute 'ALTER TABLE acao.member_services DROP CONSTRAINT member_services_pkey CASCADE'
    rename_column 'acao.member_services', 'id', 'id_old'
    rename_column 'acao.member_services', 'uuid', 'id'
    add_index 'acao.member_services', :id_old
    execute 'ALTER TABLE acao.member_services ADD CONSTRAINT member_services_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.member_services', 'service_type_id', 'acao.service_types')
    fk_to_uuid('acao.member_services', 'payment_id', 'acao.payments')
    fk_to_uuid('acao.member_services', 'person_id', 'core.people')

#    execute 'ALTER TABLE acao.invoices DROP CONSTRAINT invoices_pkey CASCADE'
#    rename_column 'acao.invoices', 'id', 'id_old'
#    rename_column 'acao.invoices', 'uuid', 'id'
#    add_index 'acao.invoices', :id_old
#    execute 'ALTER TABLE acao.invoices ADD CONSTRAINT invoices_pkey PRIMARY KEY (id)'

#    execute 'ALTER TABLE acao.invoice_details DROP CONSTRAINT invoice_details_pkey CASCADE'
#    rename_column 'acao.invoice_details', 'id', 'id_old'
#    rename_column 'acao.invoice_details', 'uuid', 'id'
#    add_index 'acao.invoice_details', :id_old
#    execute 'ALTER TABLE acao.invoice_details ADD CONSTRAINT invoice_details_pkey PRIMARY KEY (id)'
    add_foreign_key 'acao.invoice_details', 'acao.invoices', column: 'invoice_id'
    fk_to_uuid('acao.invoice_details', 'service_type_id', 'acao.service_types')

    execute 'ALTER TABLE acao.timetable_entries DROP CONSTRAINT timetable_entries_pkey CASCADE'
    rename_column 'acao.timetable_entries', 'id', 'id_old'
    rename_column 'acao.timetable_entries', 'uuid', 'id'
    add_index 'acao.timetable_entries', :id_old
    execute 'ALTER TABLE acao.timetable_entries ADD CONSTRAINT timetable_entries_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.timetable_entries', 'pilot_id', 'core.people')
    fk_to_uuid('acao.timetable_entries', 'towed_by_id', 'acao.timetable_entries')
    fk_to_uuid('acao.timetable_entries', 'landing_location_id', 'core.locations')
    fk_to_uuid('acao.timetable_entries', 'takeoff_location_id', 'core.locations')
    fk_to_uuid('acao.timetable_entries', 'takeoff_airfield_id', 'acao.airfields')
    fk_to_uuid('acao.timetable_entries', 'landing_airfield_id', 'acao.airfields')
    fk_to_uuid('acao.timetable_entries', 'tow_release_location_id', 'core.locations')
    add_foreign_key 'acao.timetable_entries', 'acao.aircrafts', column: 'aircraft_id'

    execute 'ALTER TABLE acao.token_transactions DROP CONSTRAINT token_transactions_pkey CASCADE'
    rename_column 'acao.token_transactions', 'id', 'id_old'
    rename_column 'acao.token_transactions', 'uuid', 'id'
    add_index 'acao.token_transactions', :id_old
    execute 'ALTER TABLE acao.token_transactions ADD CONSTRAINT token_transactions_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.token_transactions', 'person_id', 'core.people')
    fk_to_uuid('acao.token_transactions', 'session_id', 'core.sessions')
    add_foreign_key 'acao.token_transactions', 'acao.aircrafts', column: 'aircraft_id'

    execute 'ALTER TABLE acao.tow_roster_days DROP CONSTRAINT tow_roster_days_pkey CASCADE'
    rename_column 'acao.tow_roster_days', 'id', 'id_old'
    rename_column 'acao.tow_roster_days', 'uuid', 'id'
    add_index 'acao.tow_roster_days', :id_old
    execute 'ALTER TABLE acao.tow_roster_days ADD CONSTRAINT tow_roster_days_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE acao.tow_roster_entries DROP CONSTRAINT tow_roster_entries_pkey CASCADE'
    rename_column 'acao.tow_roster_entries', 'id', 'id_old'
    rename_column 'acao.tow_roster_entries', 'uuid', 'id'
    add_index 'acao.tow_roster_entries', :id_old
    execute 'ALTER TABLE acao.tow_roster_entries ADD CONSTRAINT tow_roster_entries_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.tow_roster_entries', 'day_id', 'acao.tow_roster_days')
    fk_to_uuid('acao.tow_roster_entries', 'person_id', 'core.people')

    execute 'ALTER TABLE acao.tows DROP CONSTRAINT tows_pkey CASCADE'
    rename_column 'acao.tows', 'id', 'id_old'
    rename_column 'acao.tows', 'uuid', 'id'
    add_index 'acao.tows', :id_old
    execute 'ALTER TABLE acao.tows ADD CONSTRAINT tows_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.tows', 'towplane_id', 'acao.aircrafts')
    fk_to_uuid('acao.tows', 'glider_id', 'acao.aircrafts')

    execute 'ALTER TABLE acao.trackers DROP CONSTRAINT trackers_pkey CASCADE'
    rename_column 'acao.trackers', 'id', 'id_old'
    rename_column 'acao.trackers', 'uuid', 'id'
    add_index 'acao.trackers', :id_old
    execute 'ALTER TABLE acao.trackers ADD CONSTRAINT trackers_pkey PRIMARY KEY (id)'
    add_foreign_key 'acao.trackers', 'acao.aircrafts', column: 'aircraft_id'

    execute 'ALTER TABLE acao.trailers DROP CONSTRAINT trailers_pkey CASCADE'
    rename_column 'acao.trailers', 'id', 'id_old'
    rename_column 'acao.trailers', 'uuid', 'id'
    add_index 'acao.trailers', :id_old
    execute 'ALTER TABLE acao.trailers ADD CONSTRAINT trailers_pkey PRIMARY KEY (id)'
    fk_to_uuid('acao.trailers', 'person_id', 'core.people')
    fk_to_uuid('acao.trailers', 'payment_id', 'acao.payments')
    fk_to_uuid('acao.trailers', 'location_id', 'core.locations')
    add_foreign_key 'acao.trailers', 'acao.aircrafts', column: 'aircraft_id'

    execute 'ALTER TABLE acao.years DROP CONSTRAINT years_pkey CASCADE'
    rename_column 'acao.years', 'id', 'id_old'
    rename_column 'acao.years', 'uuid', 'id'
    add_index 'acao.years', :id_old
    execute 'ALTER TABLE acao.years ADD CONSTRAINT years_pkey PRIMARY KEY (id)'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end


  def fk_to_uuid(from_table, column, to_table, idx_name: nil)
    null = columns(from_table).find { |x| x.name == column }.null

    if index_exists?(from_table, column)
      remove_index from_table, column
    end

    change_column_null from_table, column, true
    rename_column from_table, column, "#{column}_old"
    add_column from_table, column, :uuid
    execute "UPDATE #{from_table} SET #{column}=(SELECT id FROM #{to_table} WHERE id_old=#{column}_old)"
    add_foreign_key from_table, to_table, column: column
    change_column_null from_table, column, false if !null

    if idx_name
      add_index from_table, column, name: idx_name
    else
      add_index from_table, column
    end
  end

end

