class AddVatToServiceType < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.service_types', 'vat', :decimal, precision: 14, scale: 6, null: false, default: 0
  end
end
