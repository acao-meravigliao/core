class RemoveUnusedColumns2 < ActiveRecord::Migration[8.0]
  def up
    remove_column 'core.sessions', 'sti_type'
  end
end
