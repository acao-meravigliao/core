class CaToUuid < ActiveRecord::Migration[6.0]
  def up
    # Stores
    execute 'ALTER TABLE ca.key_stores DROP CONSTRAINT ca_key_stores_pkey CASCADE'
    rename_column 'ca.key_stores', 'id', 'id_old'
    rename_column 'ca.key_stores', 'uuid', 'id'
    #add_column 'ca.key_stores', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.key_stores', :id_old
    execute 'ALTER TABLE ca.key_stores ADD CONSTRAINT key_stores_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.key_pair_locations', 'store_id', 'ca.key_stores')
    fk_to_uuid('ca.le_slots', 'key_store_id', 'ca.key_stores')

    # Pairs
    execute 'ALTER TABLE ca.key_pairs DROP CONSTRAINT ca_private_keys_pkey CASCADE'
    rename_column 'ca.key_pairs', 'id', 'id_old'
    rename_column 'ca.key_pairs', 'uuid', 'id'
    #add_column 'ca.key_pairs', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.key_pairs', :id_old
    execute 'ALTER TABLE ca.key_pairs ADD CONSTRAINT key_pairs_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.key_pair_locations', 'pair_id', 'ca.key_pairs')
    fk_to_uuid('ca.le_accounts', 'key_pair_id', 'ca.key_pairs')
    fk_to_uuid('ca.certificates', 'key_pair_id', 'ca.key_pairs')
    fk_to_uuid('ca.cas', 'key_pair_id', 'ca.key_pairs')
    fk_to_uuid('ml.senders', 'email_dkim_key_pair_id', 'ca.key_pairs')

    # CA
    execute 'ALTER TABLE ca.cas DROP CONSTRAINT ca_cas_pkey CASCADE'
    rename_column 'ca.cas', 'id', 'id_old'
    rename_column 'ca.cas', 'uuid', 'id'
    #add_column 'ca.cas', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.cas', :id_old
    execute 'ALTER TABLE ca.cas ADD CONSTRAINT cas_pkey PRIMARY KEY (id)'


    # Certificates
    execute 'ALTER TABLE ca.certificates DROP CONSTRAINT ca_certificates_pkey CASCADE'
    rename_column 'ca.certificates', 'id', 'id_old'
    rename_column 'ca.certificates', 'uuid', 'id'
    #add_column 'ca.certificates', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.certificates', :id_old
    execute 'ALTER TABLE ca.certificates ADD CONSTRAINT certificates_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.certificate_altnames', 'certificate_id', 'ca.certificates')
    fk_to_uuid('ca.le_orders', 'certificate_id', 'ca.certificates')
    fk_to_uuid('ca.cas', 'certificate_id', 'ca.certificates')
    fk_to_uuid('ca.le_slots', 'certificate_id', 'ca.certificates')

    # Key Pair Location
    execute 'ALTER TABLE ca.key_pair_locations DROP CONSTRAINT ca_key_pair_locations_pkey CASCADE'
    rename_column 'ca.key_pair_locations', 'id', 'id_old'
    rename_column 'ca.key_pair_locations', 'uuid', 'id'
    #add_column 'ca.key_pair_locations', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.key_pair_locations', :id_old
    execute 'ALTER TABLE ca.key_pair_locations ADD CONSTRAINT key_pair_locations_pkey PRIMARY KEY (id)'
    change_column_null 'ca.key_pair_locations', 'store_id', false
    change_column_null 'ca.key_pair_locations', 'pair_id', false

    # LE accounts
    execute 'ALTER TABLE ca.le_accounts DROP CONSTRAINT ca_le_accounts_pkey CASCADE'
    rename_column 'ca.le_accounts', 'id', 'id_old'
    rename_column 'ca.le_accounts', 'uuid', 'id'
    #add_column 'ca.le_accounts', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.le_accounts', :id_old
    execute 'ALTER TABLE ca.le_accounts ADD CONSTRAINT le_accounts_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.le_slots', 'account_id', 'ca.le_accounts')
    fk_to_uuid('ca.le_orders', 'account_id', 'ca.le_accounts')

    # LE orders
    execute 'ALTER TABLE ca.le_orders DROP CONSTRAINT ca_le_orders_pkey CASCADE'
    rename_column 'ca.le_orders', 'id', 'id_old'
    rename_column 'ca.le_orders', 'uuid', 'id'
    #add_column 'ca.le_orders', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.le_orders', :id_old
    execute 'ALTER TABLE ca.le_orders ADD CONSTRAINT le_orders_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.le_order_auths', 'order_id', 'ca.le_orders')

    # LE order auth
    execute 'ALTER TABLE ca.le_order_auths DROP CONSTRAINT ca_le_order_auths_pkey CASCADE'
    rename_column 'ca.le_order_auths', 'id', 'id_old'
    rename_column 'ca.le_order_auths', 'uuid', 'id'
    #add_column 'ca.le_order_auths', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.le_order_auths', :id_old
    execute 'ALTER TABLE ca.le_order_auths ADD CONSTRAINT le_order_auths_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.le_order_auth_challenges', 'order_auth_id', 'ca.le_order_auths')

    # LE order auth challenges
    execute 'ALTER TABLE ca.le_order_auth_challenges DROP CONSTRAINT ca_le_order_auth_challenges_pkey CASCADE'
    rename_column 'ca.le_order_auth_challenges', 'id', 'id_old'
    rename_column 'ca.le_order_auth_challenges', 'uuid', 'id'
    #add_column 'ca.le_order_auth_challenges', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.le_order_auth_challenges', :id_old
    execute 'ALTER TABLE ca.le_order_auth_challenges ADD CONSTRAINT le_order_auth_challenges_pkey PRIMARY KEY (id)'

    # LE slots
    execute 'ALTER TABLE ca.le_slots DROP CONSTRAINT le_slots_pkey CASCADE'
    rename_column 'ca.le_slots', 'id', 'id_old'
    add_column 'ca.le_slots', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'ca.le_slots', :id_old
    execute 'ALTER TABLE ca.le_slots ADD CONSTRAINT le_slots_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.le_orders', 'slot_id', 'ca.le_slots')

    rename_column 'ca.le_slots', 'owner_id', 'owner_id_old'
    add_column 'ca.le_slots', 'owner_id', 'uuid'
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
