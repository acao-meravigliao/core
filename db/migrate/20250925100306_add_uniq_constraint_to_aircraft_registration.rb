class AddUniqConstraintToAircraftRegistration < ActiveRecord::Migration[8.0]
  def change
    Ygg::Acao::Aircraft.destroy_unreferenced
    remove_index 'acao.aircrafts', [ :registration ]
    add_index 'acao.aircrafts', [ :registration ], unique: true
  end
end
