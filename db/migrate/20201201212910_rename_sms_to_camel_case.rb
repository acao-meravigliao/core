class RenameSmsToCamelCase < ActiveRecord::Migration[6.0]
  def change
    execute "UPDATE core.klasses SET name='Ygg::Ml::Msg::Sms' WHERE name='Ygg::Ml::Msg::SMS'"
  end
end
