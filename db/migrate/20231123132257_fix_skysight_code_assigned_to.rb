class FixSkysightCodeAssignedTo < ActiveRecord::Migration[6.1]
  def change
    rename_column 'acao.skysight_codes', 'assigned_to', 'assigned_to_id'
  end
end
