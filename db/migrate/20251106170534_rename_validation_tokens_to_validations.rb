class RenameValidationTokensToValidations < ActiveRecord::Migration[8.0]
  def change
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'ml'"

    rename_table 'address_validation_tokens', 'address_validations'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
