class AddDebtIdToOndaInvoiceExports < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.onda_invoice_exports', 'debt_id', :uuid
  end
end
