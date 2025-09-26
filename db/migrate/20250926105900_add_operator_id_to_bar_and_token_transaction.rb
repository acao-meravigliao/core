class AddOperatorIdToBarAndTokenTransaction < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.token_transactions', 'operator_id', :uuid
    add_index 'acao.token_transactions', [ :operator_id ]
    add_column 'acao.bar_transactions', 'operator_id', :uuid
    add_index 'acao.bar_transactions', [ :operator_id ]
  end
end
