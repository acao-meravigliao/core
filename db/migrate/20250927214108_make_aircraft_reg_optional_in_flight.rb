class MakeAircraftRegOptionalInFlight < ActiveRecord::Migration[8.0]
  def change
    change_column_null 'acao.flights', 'aircraft_reg', true
  end
end
