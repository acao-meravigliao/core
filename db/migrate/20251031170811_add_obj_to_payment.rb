class AddObjToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.payments', 'obj_id', :uuid
    add_column 'acao.payments', 'obj_type', :string
  end
end
