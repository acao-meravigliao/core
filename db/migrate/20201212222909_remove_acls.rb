class RemoveAcls < ActiveRecord::Migration[6.0]
  def change
    drop_table 'core.klasses_acl'
    drop_table 'core.organizations_acl'
    drop_table 'core.people_acl'
  end
end
