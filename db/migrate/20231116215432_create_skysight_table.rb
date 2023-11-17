class CreateSkysightTable < ActiveRecord::Migration[6.1]
  def change
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao'"

    create_table :skysight_codes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :code, null: false, limit: 20
      t.timestamp :created_at, null: false, default: -> { 'now()' }
      t.timestamp :assigned_at
      t.uuid :assigned_to
    end

    add_index 'skysight_codes', [ :code ], unique: true

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
