class AddAllowedPaymentMethodsForDebt < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.debts', 'pm_card_enabled', :boolean, default: true
    add_column 'acao.debts', 'pm_wire_enabled', :boolean, default: true
    add_column 'acao.debts', 'pm_check_enabled', :boolean, default: true
    add_column 'acao.debts', 'pm_cash_enabled', :boolean, default: true
    add_column 'acao.debts', 'pm_satispay_enabled', :boolean, default: true
  end
end
