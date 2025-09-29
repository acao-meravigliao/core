class AddSourceIdToAircraft < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.aircrafts', 'source_id', :integer
    add_index 'acao.aircrafts', [ 'source_id' ]
  end
end
