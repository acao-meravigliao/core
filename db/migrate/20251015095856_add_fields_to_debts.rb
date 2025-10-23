class AddFieldsToDebts < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.debts', 'onda_export', :boolean, null: false, default: true
    add_column 'acao.debts', 'onda_export_no_reg', :boolean, null: false, default: false
  end
end
