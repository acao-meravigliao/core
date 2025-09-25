class CreateOgnDdbEntriesTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'ogn_ddb_entries', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid 'aircraft_id'
      t.timestamp 'last_update'
      t.string 'device_type', limit: 2, null: false
      t.string 'device_id', limit: 32, null: false
      t.string 'aircraft_model_id'
      t.string 'aircraft_registration'
      t.string 'aircraft_model'
      t.string 'aircraft_competition_id'
      t.boolean 'tracked'
      t.boolean 'identified'

      t.datetime "synced_at", default: -> { "now()" }, null: false
    end

    add_index 'ogn_ddb_entries', [ :device_type, :device_id ], unique: true
    add_index 'ogn_ddb_entries', [ :aircraft_registration ]

    add_foreign_key 'ogn_ddb_entries', 'aircrafts', column: 'aircraft_id', on_delete: :nullify

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.ogn_ddb_entries'
  end
end
