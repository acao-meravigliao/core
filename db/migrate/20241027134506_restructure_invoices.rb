class RestructureInvoices < ActiveRecord::Migration[7.2]
  def change
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    remove_column 'invoices', 'first_name'
    remove_column 'invoices', 'last_name'
    remove_column 'invoices', 'onda_export_filename'
    remove_column 'invoices', 'onda_no_reg'
    remove_column 'invoices', 'onda_export_status'
    remove_column 'invoices', 'last_chore'

    add_column 'invoices', 'source_id', :integer
    add_column 'invoices', 'recipient', :string, null: false
    add_column 'invoices', 'codice_fiscale', :string
    add_column 'invoices', 'partita_iva', :string
    add_column 'invoices', 'email', :string

    add_column 'invoices', 'document_date', :timestamp, default: 'now'
    add_column 'invoices', 'registered_at', :timestamp, default: 'now'

    add_column 'invoices', 'amount', :decimal, precision: 14, scale: 6, null: false, default: 0

    change_column_null 'invoices', 'member_id', true

    remove_foreign_key 'invoice_details', 'invoices', column: 'invoice_id'
    add_foreign_key 'invoice_details', 'invoices', column: 'invoice_id', on_delete: :cascade

    remove_foreign_key 'payments', 'invoices', column: 'invoice_id'
    add_foreign_key 'payments', 'invoices', column: 'invoice_id', on_delete: :cascade

    add_foreign_key 'invoices', 'core.people', column: 'person_id'
    add_index 'invoices', 'person_id'

    remove_column 'invoice_details', 'service_type_id'
    change_column_null 'invoice_details', 'count', true
    change_column_null 'invoice_details', 'price', true

    add_column 'invoices', 'document_type', :string
    add_column 'invoices', 'year', :integer

    change_column 'invoices', 'identifier', :string
    remove_index 'invoices', 'identifier', name: 'index_invoices_on_identifier'
    add_index 'invoices', 'identifier'

    add_column 'invoices', 'identifier_full', :string
    add_index 'invoices', 'identifier_full'

    add_index 'invoices', [ 'document_type', 'year', 'identifier' ]

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
