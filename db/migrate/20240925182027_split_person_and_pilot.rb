class SplitPersonAndPilot < ActiveRecord::Migration[6.1]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'members', id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.uuid 'person_id', null: false
      t.references 'ext'
      t.integer 'code'

      t.boolean 'sleeping', null: false, default: false

      t.string 'job'

      t.decimal 'bar_credit', precision: 14, scale: 6, null: false, default: 0
      t.decimal 'bollini', precision: 14, scale: 6, null: false, default: 0
      t.boolean 'roster_chief', null: false, default: false
      t.boolean 'roster_allowed', null: false, default: false
      t.boolean 'is_student', null: false, default: false
      t.boolean 'is_tug_pilot', null: false, default: false
      t.boolean 'is_board_member', null: false, default: false
      t.boolean 'is_instructor', null: false, default: false
      t.boolean 'is_fireman', null: false, default: false
      t.boolean 'has_disability', null: false, default: false
      t.boolean 'email_allowed', null: false, default: false
      t.boolean 'debtor', null: false, default: false

      t.boolean 'ml_students', null: false, default: false
      t.boolean 'ml_instructors', null: false, default: false
      t.boolean 'ml_tug_pilots', null: false, default: false
      t.boolean 'ml_blabla', null: false, default: false
      t.boolean 'ml_secondoperiodo', null: false, default: false

      t.datetime 'lastmod'
      t.datetime 'visita_lastmod'
      t.datetime 'licenza_lastmod'
      t.datetime 'bar_last_summary'
      t.datetime 'last_notify_run'
    end

    execute <<EOF
INSERT INTO acao.members (person_id,ext_id,code,sleeping,job,bar_credit,bollini,roster_chief,roster_allowed,is_student,is_tug_pilot,
                         is_board_member,is_instructor,is_fireman,has_disability,email_allowed,debtor,ml_students,ml_instructors,
                         ml_tug_pilots,ml_blabla,ml_secondoperiodo,lastmod,visita_lastmod,licenza_lastmod,bar_last_summary,last_notify_run)
  SELECT id,acao_ext_id,acao_code,acao_sleeping,acao_job,acao_bar_credit,acao_bollini,acao_roster_chief,acao_roster_allowed,acao_is_student,acao_is_tug_pilot,acao_is_board_member,acao_is_instructor,acao_is_fireman,
         acao_has_disability,acao_email_allowed,acao_debtor,acao_ml_students,acao_ml_instructors,acao_ml_tug_pilots,acao_ml_blabla,acao_ml_secondoperiodo,acao_lastmod,acao_visita_lastmod,
         acao_licenza_lastmod,acao_bar_last_summary,acao_last_notify_run FROM core.people;
EOF

    add_index 'members', :person_id, unique: true

    fk_move 'payments', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'trailers', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'member_services', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'aircrafts', 'owner_id', 'owner_id', 'acao.members', 'person_id'
    fk_move 'roster_entries', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'key_fobs', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'memberships', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'fai_cards', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'timetable_entries', 'pilot_id', 'pilot_id', 'acao.members', 'person_id'
    fk_move 'tow_roster_entries', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'invoices', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'medicals', 'pilot_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'licenses', 'pilot_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'meters', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'bar_transactions', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'token_transactions', 'person_id', 'member_id', 'acao.members', 'person_id'
    fk_move 'flights', 'pilot1_id', 'pilot1_id', 'acao.members', 'person_id'
    fk_move 'flights', 'pilot2_id', 'pilot2_id', 'acao.members', 'person_id'
    fk_move 'flights', 'aircraft_owner_id', 'aircraft_owner_id', 'acao.members', 'person_id'

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.members'
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
