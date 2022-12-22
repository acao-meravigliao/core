class CreateAcaoCameraEventsTable < ActiveRecord::Migration[6.0]
  def change
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'autocam_camera_events', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :event_type, limit: 32, null: false
      t.timestamp :ts
      t.uuid :aircraft_id
      t.string :name
      t.string :flarm_id, limit: 32
      t.float :lat
      t.float :lng
      t.float :alt
      t.float :hgt
    end

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
