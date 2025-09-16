class AddRejectCauseToOndaInvoiceExport < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.onda_invoice_exports', 'reject_cause', :string
  end
end
