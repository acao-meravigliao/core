class CreateRolesTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'roles', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.string :symbol
      t.string :descr
      t.string :icon
      t.boolean :usable, null: false, default: true
    end

    add_index 'roles', [ :symbol ], unique: true

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.roles'
  end
end
