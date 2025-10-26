class AddDebtCardColumnToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.debts', 'pm_debt_enabled', :boolean, default: true
  end
end
