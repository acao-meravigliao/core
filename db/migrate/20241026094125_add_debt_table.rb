class AddDebtTable < ActiveRecord::Migration[7.2]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'debts', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid 'member_id', null: false
      t.string 'identifier', limit: 32, null: false
      t.string 'state', limit: 32, null: false
      t.string 'descr', null: false
      t.timestamp 'completed_at'
      t.timestamp 'expires_at'
      t.string 'notes'
      t.timestamp 'last_chore'

      t.datetime "synced_at", default: -> { "now()" }, null: false
    end

    add_index 'debts', [ :identifier ], unique: true
    add_index 'debts', [ :member_id ]
    add_index 'debts', [ :state ]

    create_table 'debt_details', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid 'debt_id', null: false
      t.integer 'count', null: false
      t.string 'code'
      t.string 'descr', null: false
      t.decimal 'amount', precision: 14, scale: 6, null: false
      t.decimal 'vat', precision: 14, scale: 6, null: false
      t.string 'data'
      t.uuid 'service_type_id'
      t.string 'obj_type'
      t.uuid 'obj_id'
    end

    add_index 'debt_details', [ :debt_id ]
    add_index 'debt_details', [ :service_type_id ]
    add_index 'debt_details', [ :obj_type, :obj_id ]

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.debt_details'
    drop_table 'acao.debts'
  end
end
