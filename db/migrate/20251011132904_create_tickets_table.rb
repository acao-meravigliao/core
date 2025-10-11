class CreateTicketsTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'tickets', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.serial :number
      t.integer :number_short
      t.uuid 'member_id'
      t.string 'state', default: 'NEW', null: false
      t.uuid :aircraft_id
      t.uuid :takeoff_airfield_id
      t.uuid :landing_airfield_id
      t.uuid :pilot1_id
      t.string :pilot1_role
      t.uuid :pilot2_id
      t.string :pilot2_role
      t.integer :tipo_volo_club
      t.integer :bollini
      t.integer :height
      t.string :launch_type, limit: 16
      t.string :aircraft_class, limit: 16
      t.boolean :instruction_flight
      t.boolean :skill_test
      t.boolean :proficiency_test
      t.boolean :maintenance_flight
      t.string :source
      t.integer :source_id
    end

    add_index 'tickets', [ :number ], unique: true
    add_index 'tickets', [ :member_id ]

    add_foreign_key 'tickets', 'aircrafts', column: 'aircraft_id'
    add_foreign_key 'tickets', 'members', column: 'member_id', on_delete: :nullify
    add_foreign_key 'tickets', 'members', column: 'pilot1_id', on_delete: :nullify
    add_foreign_key 'tickets', 'members', column: 'pilot2_id', on_delete: :nullify
    add_foreign_key 'tickets', 'airfields', column: 'takeoff_airfield_id'
    add_foreign_key 'tickets', 'airfields', column: 'landing_airfield_id'

    ActiveRecord::Base.connection.schema_search_path = current_schema

  end

  def down
    drop_table 'acao.tickets'
  end
end
