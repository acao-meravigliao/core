class AddMemberToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.payments', 'member_id', :uuid

    add_index 'acao.payments', :member_id
    add_foreign_key 'acao.payments', 'acao.members', column: 'member_id'
  end
end
