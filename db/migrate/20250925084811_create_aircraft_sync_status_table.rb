class CreateAircraftSyncStatusTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'aircraft_sync_statuses', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.string 'symbol', limit: 16
      t.timestamp 'last_update'
      t.string 'status'
    end

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.aircraft_sync_statuses'
  end
end
