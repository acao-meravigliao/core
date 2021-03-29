class FixFlightsTowedBy < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key 'acao.flights', column: 'towed_by_id'
    execute 'UPDATE acao.flights SET towed_by_id=(SELECT id FROM acao.flights WHERE acao.flights.id_old=towed_by_id_old)'
    add_foreign_key 'acao.flights', 'acao.flights', column: 'towed_by_id'
  end
end
