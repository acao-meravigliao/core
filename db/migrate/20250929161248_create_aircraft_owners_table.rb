class CreateAircraftOwnersTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'aircraft_owners', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :aircraft_id, null: true
      t.uuid :member_id, null: true
      t.boolean :is_referent, null: false, default: false
    end

    add_foreign_key 'aircraft_owners', 'aircrafts', column: 'aircraft_id'
    add_foreign_key 'aircraft_owners', 'members', column: 'member_id'

    add_index 'aircraft_owners', [ :aircraft_id, :member_id ], unique: true
    add_index 'aircraft_owners', [ :aircraft_id ]
    add_index 'aircraft_owners', [ :member_id ]

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.aircraft_owners'
  end
end
