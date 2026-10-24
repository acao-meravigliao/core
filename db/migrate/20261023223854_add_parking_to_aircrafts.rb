class AddParkingToAircrafts < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.aircrafts', 'parking', :string, limit: 32
  end
end
