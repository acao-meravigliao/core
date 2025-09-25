class AddFlarmnetTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'flarmnet_entries', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid 'aircraft_id'
      t.timestamp 'last_update'
      t.string 'device_type', limit: 2, null: false
      t.string 'device_id', limit: 32, null: false
      t.string 'registration'
      t.string 'aircraft_model'
      t.string 'cn'
      t.boolean 'tracked'
      t.boolean 'identified'
    end

    add_index 'flarmnet_entries', [ :device_type, :device_id ], unique: true
    add_index 'flarmnet_entries', [ :registration ]

    add_foreign_key 'flarmnet_entries', 'aircrafts', column: 'aircraft_id', on_delete: :nullify

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.flarmnet_entries'
  end
end
