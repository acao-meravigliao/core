class AddAirfieldCircuits < ActiveRecord::Migration[6.0]
  def change
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'airfield_circuits', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :airfield_id, null: false
      t.string :name, limit: 64, null: false
      t.text :data, null: false
    end

    add_foreign_key 'airfield_circuits', 'airfields', column: 'airfield_id'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
