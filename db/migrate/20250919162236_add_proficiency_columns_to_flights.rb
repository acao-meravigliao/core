class AddProficiencyColumnsToFlights < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.flights', 'proficiency_check', :bool, null: false, default: false
    add_column 'acao.flights', 'skill_test', :bool, null: false, default: false
    add_column 'acao.flights', 'maintenance_flight', :bool, null: false, default: false
    add_column 'acao.flights', 'purpose', :string, limit: 32
  end
end
