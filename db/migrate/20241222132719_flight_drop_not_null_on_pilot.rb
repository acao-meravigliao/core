class FlightDropNotNullOnPilot < ActiveRecord::Migration[7.2]
  def change
    change_column_null 'acao.flights', 'pilot1_id', true
  end
end
