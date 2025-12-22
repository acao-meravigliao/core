class FixPaymentInvoiceIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index 'acao.payments', :invoice_id, unique: true
    add_index 'acao.payments', :invoice_id
  end
end
