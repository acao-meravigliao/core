class I18nToUuid < ActiveRecord::Migration[6.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.create_schema 'i18n'
    ActiveRecord::Base.connection.schema_search_path = "'i18n', 'public'"

    # Languages
    execute "ALTER TABLE i18n_languages SET SCHEMA i18n"
    rename_table 'i18n_languages', 'languages'

    execute 'ALTER TABLE i18n.languages DROP CONSTRAINT languages_pkey CASCADE'
    rename_column 'i18n.languages', 'id', 'id_old'
    rename_column 'i18n.languages', 'uuid', 'id'
    #add_column 'i18n.languages', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'i18n.languages', :id_old
    execute 'ALTER TABLE i18n.languages ADD CONSTRAINT languages_pkey PRIMARY KEY (id)'

    execute 'ALTER TABLE core.notif_templates ALTER COLUMN id TYPE uuid USING id::uuid'

    add_column 'core.notif_templates', 'language_id', 'uuid'
    add_foreign_key 'core.notif_templates', 'i18n.languages', column: 'language_id'
    change_column_null 'core.notif_templates', 'language_id', false

    fk_to_uuid('core.people', 'preferred_language_id', 'i18n.languages')
    fk_to_uuid('core.sessions', 'language_id', 'i18n.languages')
    fk_to_uuid('i18n_translations', 'language_id', 'i18n.languages')
    fk_to_uuid('ml.templates', 'language_id', 'i18n.languages')

    # Phrases
    execute "ALTER TABLE i18n_phrases SET SCHEMA i18n"
    rename_table 'i18n_phrases', 'phrases'

    execute 'ALTER TABLE i18n.phrases DROP CONSTRAINT phrases_pkey CASCADE'
    rename_column 'i18n.phrases', 'id', 'id_old'
    rename_column 'i18n.phrases', 'uuid', 'id'
    #add_column 'i18n.phrases', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'i18n.phrases', :id_old
    execute 'ALTER TABLE i18n.phrases ADD CONSTRAINT phrases_pkey PRIMARY KEY (id)'

    fk_to_uuid('i18n_translations', 'phrase_id', 'i18n.phrases')

    # Translations
    execute "ALTER TABLE i18n_translations SET SCHEMA i18n"
    rename_table 'i18n_translations', 'translations'

    execute 'ALTER TABLE i18n.translations DROP CONSTRAINT translations_pkey CASCADE'
    rename_column 'i18n.translations', 'id', 'id_old'
    rename_column 'i18n.translations', 'uuid', 'id'
    #add_column 'i18n.translations', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'i18n.translations', :id_old
    execute 'ALTER TABLE i18n.translations ADD CONSTRAINT translations_pkey PRIMARY KEY (id)'
  end

  def fk_to_uuid(from_table, column, to_table, idx_name: nil)
    null = columns(from_table).find { |x| x.name == column }.null

    if index_exists?(from_table, column)
      remove_index from_table, column
    end

    change_column_null from_table, column, true
    rename_column from_table, column, "#{column}_old"
    add_column from_table, column, :uuid
    execute "UPDATE #{from_table} SET #{column}=(SELECT id FROM #{to_table} WHERE id_old=#{column}_old)"
    add_foreign_key from_table, to_table, column: column
    change_column_null from_table, column, false if !null

    if idx_name
      add_index from_table, column, name: idx_name
    else
      add_index from_table, column
    end
  end
end
