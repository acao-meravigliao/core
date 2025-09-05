class AddFieldsToInvoiceDetails < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.invoice_details', 'row_type', :integer
    add_column 'acao.invoice_details', 'row_number', :integer
    add_column 'acao.invoice_details', 'code', :string, limit: 32
    add_column 'acao.invoice_details', 'single_amount',  :decimal, precision: 14, scale: 6
    rename_column 'acao.invoice_details', 'price', 'untaxed_amount'
    add_column 'acao.invoice_details', 'vat_amount',  :decimal, precision: 14, scale: 6
    add_column 'acao.invoice_details', 'total_amount', :decimal, precision: 14, scale: 6
  end
end
