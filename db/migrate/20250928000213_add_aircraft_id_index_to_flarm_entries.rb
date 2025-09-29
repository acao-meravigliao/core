class AddAircraftIdIndexToFlarmEntries < ActiveRecord::Migration[8.0]
  def change
    add_index 'acao.flarmnet_entries', [ :aircraft_id ]
    add_index 'acao.ogn_ddb_entries', [ :aircraft_id ]
  end
end
