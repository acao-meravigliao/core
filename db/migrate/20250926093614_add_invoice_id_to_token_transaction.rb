class AddInvoiceIdToTokenTransaction < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.token_transactions', 'invoice_id', :uuid
    add_index 'acao.token_transactions', [ :invoice_id ]
  end
end
