class AddOndaInvoiceExportsTable < ActiveRecord::Migration[7.2]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'onda_invoice_exports', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid 'member_id', null: false
      t.string 'identifier', limit: 32, null: false
      t.string 'state', default: 'PENDING'
      t.string 'descr', null: false
      t.string 'notes'
      t.string 'payment_method', limit: 32
      t.timestamp 'last_chore'

      t.datetime "synced_at", default: -> { "now()" }, null: false
    end

    add_index 'onda_invoice_exports', [ :member_id ]
    add_index 'onda_invoice_exports', [ :identifier ], unique: true
    add_index 'onda_invoice_exports', [ :state ]

    create_table 'onda_invoice_export_details', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid 'onda_invoice_export_id', null: false
      t.integer 'count', null: false
      t.string 'code', limit: 32, null: false
      t.integer 'item_type', null: false
      t.string 'descr', null: false
      t.decimal 'amount', precision: 14, scale: 6, null: false
      t.decimal 'vat', precision: 14, scale: 6, null: false
    end

    add_index 'onda_invoice_export_details', [ :onda_invoice_export_id ]

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.onda_invoice_export_details'
    drop_table 'acao.onda_invoice_exports'
  end
end
