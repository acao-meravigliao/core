class AddRowIndexToDebts < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.debt_details', 'row_index', :integer, null: false, default: 1
  end
end
