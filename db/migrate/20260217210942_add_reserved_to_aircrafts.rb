class AddReservedToAircrafts < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.aircrafts', 'reserved', :boolean, null: false, default: false
    rename_column 'acao.aircrafts', 'available', 'flyable'
  end
end
