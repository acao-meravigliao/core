class AddDebtIdToInvoces < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.invoices', 'debt_id', :uuid
    add_index 'acao.invoices', :debt_id, unique: true
    add_foreign_key 'acao.invoices', 'acao.debts', column: 'debt_id', on_delete: :nullify

    add_column 'acao.payments', 'invoice_id', :uuid
    add_index 'acao.payments', :invoice_id, unique: true
    add_foreign_key 'acao.payments', 'acao.invoices', column: 'invoice_id', on_delete: :nullify

    add_column 'acao.invoices', 'our_reference', :string
    add_index 'acao.invoices', 'our_reference'

    add_column 'acao.onda_invoice_exports', 'our_reference', :string
  end
end
