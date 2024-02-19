class CreateAccessRemotes < ActiveRecord::Migration[6.1]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table :access_remotes, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :symbol, limit: 32
      t.string :ch1_code, limit: 32
      t.string :ch2_code, limit: 32
      t.string :ch3_code, limit: 32
      t.string :ch4_code, limit: 32
      t.string :descr
    end

    add_index 'access_remotes', [ :symbol ], unique: true

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.access_remotes'
  end
end
