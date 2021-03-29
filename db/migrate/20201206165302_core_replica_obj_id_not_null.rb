class CoreReplicaObjIdNotNull < ActiveRecord::Migration[6.0]
  def change
    execute 'DELETE FROM core.replicas WHERE obj_id IS NULL'
    change_column_null 'core.replicas', 'obj_id', false
  end
end
