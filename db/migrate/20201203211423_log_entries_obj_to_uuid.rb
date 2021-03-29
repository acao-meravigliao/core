class LogEntriesObjToUuid < ActiveRecord::Migration[6.0]
  def change
    execute "UPDATE core.log_entry_details SET obj_uuid=NULL WHERE obj_uuid=''"
    rename_column 'core.log_entry_details', 'obj_id', 'obj_id_old'
    change_column 'core.log_entry_details', 'obj_uuid', 'uuid USING obj_uuid::uuid'
    rename_column 'core.log_entry_details', 'obj_uuid', 'obj_id'
    add_index 'core.log_entry_details', [ :obj_type, :obj_id ]
  end
end
