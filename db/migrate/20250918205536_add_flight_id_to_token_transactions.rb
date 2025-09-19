class AddFlightIdToTokenTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.token_transactions', 'flight_id', :uuid
  end
end
