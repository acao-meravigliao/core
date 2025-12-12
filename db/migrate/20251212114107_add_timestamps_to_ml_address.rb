class AddTimestampsToMlAddress < ActiveRecord::Migration[8.1]
  def change
    add_column 'ml.addresses', 'created_at', :timestamptz
    add_column 'ml.addresses', 'updated_at', :timestamptz
  end
end
