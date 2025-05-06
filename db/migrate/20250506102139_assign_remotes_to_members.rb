class AssignRemotesToMembers < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    rename_table 'person_access_remotes', 'member_access_remotes'

    fk_move 'member_access_remotes', 'person_id', 'member_id', 'acao.members', 'person_id'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def fk_move(table, from_column, to_column, to_table, foreign_column, idx_name: nil)
    null = columns(table).find { |x| x.name == from_column }.null

    old_from_column = from_column

    if index_exists?(table, from_column)
      remove_index table, from_column
    end

    foreign_keys(table).each do |fk|
      if fk.options[:column] == from_column.to_s
        remove_foreign_key table, name: fk.options[:name]
      end
    end

    change_column_null table, from_column, true

    if from_column == to_column
      old_from_column = "#{from_column}_old"
      rename_column table, from_column, old_from_column
    end

    add_column table, to_column, :uuid

    execute "UPDATE #{table} SET #{to_column}=(SELECT id FROM #{to_table} WHERE #{foreign_column}=#{table}.#{old_from_column})"

    add_foreign_key table, to_table, column: to_column
    change_column_null table, to_column, false if !null

    if idx_name
      add_index table, to_column, name: idx_name
    else
      add_index table, to_column
    end
  end

end
