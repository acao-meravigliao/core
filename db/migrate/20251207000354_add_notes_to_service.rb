class AddNotesToService < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.member_services', 'notes_internal', :text
    add_column 'acao.member_services', 'notes_public', :text
  end
end
