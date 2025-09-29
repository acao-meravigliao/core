class AddFlightIdIndexToTokenTransaction < ActiveRecord::Migration[8.0]
  def change
    add_index 'acao.token_transactions', [ :flight_id ]
  end
end
