class AddStaticPilotNamesToFlight < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.flights', 'pilot1_name', :string
    add_column 'acao.flights', 'pilot2_name', :string
  end
end
