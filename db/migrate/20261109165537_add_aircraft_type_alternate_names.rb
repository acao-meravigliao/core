class AddAircraftTypeAlternateNames < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.aircraft_types', 'ogn_ddb_name', :string
  end
end
