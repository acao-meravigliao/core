class AddCavExemptToMember < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.members', 'cav_exempt', :boolean, null: false, default: false
  end
end
