class MlToUuid < ActiveRecord::Migration[6.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'ml', 'public'"

    # Address
    execute 'ALTER TABLE ml.addresses DROP CONSTRAINT ml_addresses_pkey CASCADE'
    rename_column 'ml.addresses', 'id', 'id_old'
    rename_column 'ml.addresses', 'uuid', 'id'
    add_index 'ml.addresses', :id_old
    execute 'ALTER TABLE ml.addresses ADD CONSTRAINT addresses_pkey PRIMARY KEY (id)'
    fk_to_uuid('ml.list_members', 'address_id', 'ml.addresses')
    fk_to_uuid('ml.msgs', 'recipient_id', 'ml.addresses')

    # List
    execute 'ALTER TABLE ml.lists DROP CONSTRAINT ml_lists_pkey CASCADE'
    rename_column 'ml.lists', 'id', 'id_old'
    rename_column 'ml.lists', 'uuid', 'id'
    #add_column 'ml.lists', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.lists', :id_old
    execute 'ALTER TABLE ml.lists ADD CONSTRAINT lists_pkey PRIMARY KEY (id)'
    fk_to_uuid('ml.list_members', 'list_id', 'ml.lists')
    fk_to_uuid('ml.msg_lists', 'list_id', 'ml.lists')

    # List Members
    execute 'ALTER TABLE ml.list_members DROP CONSTRAINT ml_list_members_pkey CASCADE'
    rename_column 'ml.list_members', 'id', 'id_old'
    add_column 'ml.list_members', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.list_members', :id_old
    execute 'ALTER TABLE ml.list_members ADD CONSTRAINT list_members_pkey PRIMARY KEY (id)'

    rename_column 'ml.list_members', 'owner_id', 'owner_id_old'
    add_column 'ml.list_members', 'owner_id', :uuid
    execute "UPDATE ml.list_members SET owner_id=(SELECT id FROM core.people WHERE id_old=owner_id_old) WHERE owner_type='Ygg::Core::Person'"

    # Msg
    execute 'ALTER TABLE ml.msgs DROP CONSTRAINT ml_msgs_pkey CASCADE'
    rename_column 'ml.msgs', 'id', 'id_old'
    rename_column 'ml.msgs', 'uuid', 'id'
    #add_column 'ml.msgs', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.msgs', :id_old
    execute 'ALTER TABLE ml.msgs ADD CONSTRAINT msgs_pkey PRIMARY KEY (id)'
    fk_to_uuid('ml.msg_bounces', 'msg_id', 'ml.msgs')
    fk_to_uuid('ml.msg_lists', 'msg_id', 'ml.msgs')
    fk_to_uuid('ml.msg_objects', 'msg_id', 'ml.msgs')
    fk_to_uuid('ml.msg_events', 'msg_id', 'ml.msgs')

    # Msg Bounce
    execute 'ALTER TABLE ml.msg_bounces DROP CONSTRAINT ml_msg_bounces_pkey CASCADE'
    rename_column 'ml.msg_bounces', 'id', 'id_old'
    rename_column 'ml.msg_bounces', 'uuid', 'id'
    #add_column 'ml.msg_bounces', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.msg_bounces', :id_old
    execute 'ALTER TABLE ml.msg_bounces ADD CONSTRAINT msg_bounces_pkey PRIMARY KEY (id)'

    # List
    execute 'ALTER TABLE ml.msg_lists DROP CONSTRAINT ml_msg_lists_pkey CASCADE'
    rename_column 'ml.msg_lists', 'id', 'id_old'
    add_column 'ml.msg_lists', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.msg_lists', :id_old
    execute 'ALTER TABLE ml.msg_lists ADD CONSTRAINT msg_lists_pkey PRIMARY KEY (id)'

    # Object
    execute 'ALTER TABLE ml.msg_objects DROP CONSTRAINT ml_msg_objects_pkey CASCADE'
    rename_column 'ml.msg_objects', 'id', 'id_old'
    add_column 'ml.msg_objects', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.msg_objects', :id_old
    execute 'ALTER TABLE ml.msg_objects ADD CONSTRAINT msg_objects_pkey PRIMARY KEY (id)'

    rename_column 'ml.msg_objects', 'object_id', 'object_id_old'
    add_column 'ml.msg_objects', 'object_id', :uuid

    # Sender
    execute 'ALTER TABLE ml.senders DROP CONSTRAINT ml_senders_pkey CASCADE'
    rename_column 'ml.senders', 'id', 'id_old'
    rename_column 'ml.senders', 'uuid', 'id'
    #add_column 'ml.senders', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.senders', :id_old
    execute 'ALTER TABLE ml.senders ADD CONSTRAINT senders_pkey PRIMARY KEY (id)'

    fk_to_uuid('ml.msgs', 'sender_id', 'ml.senders')

    # Template
    execute 'ALTER TABLE ml.templates DROP CONSTRAINT ml_templates_pkey CASCADE'
    rename_column 'ml.templates', 'id', 'id_old'
    rename_column 'ml.templates', 'uuid', 'id'
    #add_column 'ml.templates', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ml.templates', :id_old
    execute 'ALTER TABLE ml.templates ADD CONSTRAINT templates_pkey PRIMARY KEY (id)'
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
