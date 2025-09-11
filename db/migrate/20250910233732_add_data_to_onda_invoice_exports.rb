class AddDataToOndaInvoiceExports < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.onda_invoice_export_details', 'data', :string
  end
end
