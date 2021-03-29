class SetCoreCredentialsIdDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default 'core.person_credentials', 'id', lambda { 'gen_random_uuid()' }
  end
end
