class CreatePersonAccessRemote < ActiveRecord::Migration[6.1]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'person_access_remotes', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :symbol, limit: 32
      t.uuid :person_id, null: false
      t.uuid :remote_id, null: false
      t.string :descr
    end

    add_index 'person_access_remotes', [ :remote_id ], unique: true

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.person_access_remotes'
  end
end
