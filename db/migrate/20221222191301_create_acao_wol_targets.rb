class CreateAcaoWolTargets < ActiveRecord::Migration[6.1]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'wol_targets', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.string :symbol, limit: 32, null: true
      t.string :name, limit: 64, null: false
      t.string :interface, limit: 64, null: false
      t.macaddr :mac, null: false
    end

    add_index 'wol_targets', [ :symbol ], unique: true

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.wol_targets'
  end
end
