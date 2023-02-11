class AddIsMigrationColumn < ActiveRecord::Migration[6.1]
  def up
    add_column 'acao.service_types', 'is_association', :bool

    a=Ygg::Acao::ServiceType.find_by(symbol: 'ASS_STANDARD') ; a.is_association = true; a.save!
    a=Ygg::Acao::ServiceType.find_by(symbol: 'ASS_23') ; a.is_association = true; a.save!
  end
end
