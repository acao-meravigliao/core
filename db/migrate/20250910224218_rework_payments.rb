class ReworkPayments < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    add_column 'payments', 'debt_id', :uuid
    add_index 'payments', [ :debt_id ]

    remove_column 'payments', 'person_id'
    remove_column 'payments', 'member_id'
    remove_column 'payments', 'invoice_id'
    remove_column 'payments', 'onda_export_status'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    remove_column 'payments', 'debt_id'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end
end
