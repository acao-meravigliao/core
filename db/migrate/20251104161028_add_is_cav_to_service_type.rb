class AddIsCavToServiceType < ActiveRecord::Migration[8.0]
  def change
    Ygg::Acao::ServiceType.where(is_association: nil).update_all(is_association: false)

    add_column 'acao.service_types', 'is_cav', :boolean, null: false, default: false
    change_column 'acao.service_types', 'is_association', :boolean, null: false, default: false

    Ygg::Acao::ServiceType.where("symbol LIKE 'CAV%'").update_all(is_cav: true)
  end
end
