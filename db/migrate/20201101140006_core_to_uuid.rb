class CoreToUuid < ActiveRecord::Migration[6.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.create_schema 'core'
    ActiveRecord::Base.connection.schema_search_path = "'core', 'public'"

    # Cleanup

    remove_column 'core_log_entries', 'identity_id'
    drop_table 'core_identities_acl'
    drop_table 'core_readables_uuid'

    # Agents
    execute "ALTER TABLE core_agents SET SCHEMA core"
    rename_table 'core_agents', 'agents'

    execute 'ALTER TABLE core.agents DROP CONSTRAINT agents_pkey CASCADE'
    rename_column 'core.agents', 'id', 'id_old'
    rename_column 'core.agents', 'uuid', 'id'
    #add_column 'core.agents', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.agents', :id_old
    execute 'ALTER TABLE core.agents ADD CONSTRAINT agents_pkey PRIMARY KEY (id)'

    fk_to_uuid('ca.key_stores', 'remote_agent_id', 'core.agents')

    # Global Roles
    execute "ALTER TABLE core_global_roles SET SCHEMA core"
    execute 'ALTER TABLE core_global_roles DROP CONSTRAINT core_capabilities_pkey CASCADE'
    rename_table 'core_global_roles', 'global_roles'
    rename_column 'core.global_roles', 'id', 'id_old'
    rename_column 'core.global_roles', 'uuid', 'id'
    #add_column 'core.global_roles', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.global_roles', :id_old
    execute 'ALTER TABLE core.global_roles ADD CONSTRAINT global_roles_pkey PRIMARY KEY (id)'

    fk_to_uuid('core_person_roles', 'global_role_id', 'core.global_roles')

    # Group Members
    execute "ALTER TABLE core_group_members SET SCHEMA core"
    rename_table 'core_group_members', 'group_members'

    execute 'ALTER TABLE core.group_members DROP CONSTRAINT group_members_pkey CASCADE'
    rename_column 'core.group_members', 'id', 'id_old'
    add_column 'core.group_members', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.group_members', :id_old
    execute 'ALTER TABLE core.group_members ADD CONSTRAINT group_members_pkey PRIMARY KEY (id)'

    # ISO countries
    execute "ALTER TABLE core_iso_countries SET SCHEMA core"
    rename_table 'core_iso_countries', 'iso_countries'

    # Klasses
    execute "ALTER TABLE core_klasses SET SCHEMA core"
    rename_table 'core_klasses', 'klasses'

    execute " UPDATE core_klass_members_role_defs SET uuid=gen_random_uuid() WHERE uuid=''"
    execute 'ALTER TABLE core.klasses DROP CONSTRAINT klasses_pkey CASCADE'
    rename_column 'core.klasses', 'id', 'id_old'
    rename_column 'core.klasses', 'uuid', 'id'
    #add_column 'core.klasses', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.klasses', :id_old
    execute 'ALTER TABLE core.klasses ADD CONSTRAINT klasses_pkey PRIMARY KEY (id)'
    fk_to_uuid('core_klass_collection_role_defs', 'klass_id', 'core.klasses')
    fk_to_uuid('core_klass_members_role_defs', 'klass_id', 'core.klasses')

    # Klasses ACL
    execute "ALTER TABLE core_klasses_acl SET SCHEMA core"
    rename_table 'core_klasses_acl', 'klasses_acl'

    # Klass Member Role Defs
    execute "ALTER TABLE core_klass_members_role_defs SET SCHEMA core"
    rename_table 'core_klass_members_role_defs', 'klass_members_role_defs'

    execute 'ALTER TABLE core.klass_members_role_defs DROP CONSTRAINT klass_members_role_defs_pkey CASCADE'
    rename_column 'core.klass_members_role_defs', 'id', 'id_old'
    rename_column 'core.klass_members_role_defs', 'uuid', 'id'
    #add_column 'core.klass_members_role_defs', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.klass_members_role_defs', :id_old
    execute 'ALTER TABLE core.klass_members_role_defs ADD CONSTRAINT klass_members_role_defs_pkey PRIMARY KEY (id)'

    # Klass Collecion Role Defs
    execute "ALTER TABLE core_klass_collection_role_defs SET SCHEMA core"
    rename_table 'core_klass_collection_role_defs', 'klass_collection_role_defs'

    execute 'ALTER TABLE core.klass_collection_role_defs DROP CONSTRAINT klass_collection_role_defs_pkey CASCADE'
    rename_column 'core.klass_collection_role_defs', 'id', 'id_old'
    add_column 'core.klass_collection_role_defs', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.klass_collection_role_defs', :id_old
    execute 'ALTER TABLE core.klass_collection_role_defs ADD CONSTRAINT klass_collection_role_defs_pkey PRIMARY KEY (id)'

    # Locations
    execute "ALTER TABLE core_locations SET SCHEMA core"
    rename_table 'core_locations', 'locations'

    execute 'ALTER TABLE core.locations DROP CONSTRAINT locations_pkey CASCADE'
    rename_column 'core.locations', 'id', 'id_old'
    rename_column 'core.locations', 'uuid', 'id'
    #add_column 'core.locations', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.locations', :id_old
    execute 'ALTER TABLE core.locations ADD CONSTRAINT locations_pkey PRIMARY KEY (id)'

    fk_to_uuid('core_organizations', 'headquarters_location_id', 'core.locations')
    fk_to_uuid('core_organizations', 'invoicing_location_id', 'core.locations')
    fk_to_uuid('core_organizations', 'registered_office_location_id', 'core.locations')
    fk_to_uuid('core_people', 'birth_location_id', 'core.locations')
    fk_to_uuid('core_people', 'invoicing_location_id', 'core.locations')
    fk_to_uuid('core_people', 'residence_location_id', 'core.locations')

    # Log Entries
    execute "ALTER TABLE core_log_entries SET SCHEMA core"
    rename_table 'core_log_entries', 'log_entries'

    execute 'ALTER TABLE core.log_entries DROP CONSTRAINT log_entries_pkey CASCADE'
    rename_column 'core.log_entries', 'id', 'id_old'
    rename_column 'core.log_entries', 'uuid', 'id'
    #add_column 'core.log_entries', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.log_entries', :id_old
    execute 'ALTER TABLE core.log_entries ADD CONSTRAINT log_entries_pkey PRIMARY KEY (id)'

    fk_to_uuid('core_log_entry_details', 'log_entry_id', 'core.log_entries')

    rename_column 'core.log_entries', 'transaction_uuid', 'transaction_id'

    # Log Entry Details
    execute "ALTER TABLE core_log_entry_details SET SCHEMA core"
    rename_table 'core_log_entry_details', 'log_entry_details'

    execute 'ALTER TABLE core.log_entry_details DROP CONSTRAINT log_entry_details_pkey CASCADE'
    rename_column 'core.log_entry_details', 'id', 'id_old'
    add_column 'core.log_entry_details', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.log_entry_details', :id_old
    execute 'ALTER TABLE core.log_entry_details ADD CONSTRAINT log_entry_details_pkey PRIMARY KEY (id)'

    # Notifications
    execute "ALTER TABLE core_notifications SET SCHEMA core"
    rename_table 'core_notifications', 'notifications'

    execute 'ALTER TABLE core.notifications DROP CONSTRAINT notifications_pkey CASCADE'
    rename_column 'core.notifications', 'id', 'id_old'
    rename_column 'core.notifications', 'uuid', 'id'
    #add_column 'core.notifications', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.notifications', :id_old
    execute 'ALTER TABLE core.notifications ADD CONSTRAINT notifications_pkey PRIMARY KEY (id)'

    rename_column 'core.notifications', 'obj_id', 'obj_id_old'
    add_column 'core.notifications', 'obj_id', :uuid

    # Notif Templates
    execute "ALTER TABLE core_notif_templates SET SCHEMA core"
    rename_table 'core_notif_templates', 'notif_templates'

    execute 'ALTER TABLE core.notif_templates DROP CONSTRAINT notif_templates_pkey CASCADE'
    rename_column 'core.notif_templates', 'id', 'id_old'
    rename_column 'core.notif_templates', 'uuid', 'id'
    #add_column 'core.notif_templates', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.notif_templates', :id_old
    execute 'ALTER TABLE core.notif_templates ADD CONSTRAINT notif_templates_pkey PRIMARY KEY (id)'

    # Organizations
    execute "ALTER TABLE core_organizations SET SCHEMA core"
    rename_table 'core_organizations', 'organizations'

    execute 'ALTER TABLE core.organizations DROP CONSTRAINT organizations_pkey CASCADE'
    rename_column 'core.organizations', 'id', 'id_old'
    rename_column 'core.organizations', 'uuid', 'id'
    #add_column 'core.organizations', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.organizations', :id_old
    execute 'ALTER TABLE core.organizations ADD CONSTRAINT organizations_pkey PRIMARY KEY (id)'

    remove_index 'core_organization_people', [ 'organization_id', 'person_id' ]

    fk_to_uuid('core_organization_people', 'organization_id', 'core.organizations')
    fk_to_uuid('core_organizations_acl', 'obj_id', 'core.organizations')

    # Organizations ACL
    execute "ALTER TABLE core_organizations_acl SET SCHEMA core"
    rename_table 'core_organizations_acl', 'organizations_acl'

    # Organization People
    execute "ALTER TABLE core_organization_people SET SCHEMA core"
    rename_table 'core_organization_people', 'organization_people'

    execute 'ALTER TABLE core.organization_people DROP CONSTRAINT organization_people_pkey CASCADE'
    rename_column 'core.organization_people', 'id', 'id_old'
    add_column 'core.organization_people', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.organization_people', :id_old
    execute 'ALTER TABLE core.organization_people ADD CONSTRAINT organization_people_pkey PRIMARY KEY (id)'

    # People
    execute "ALTER TABLE core_people SET SCHEMA core"
    rename_table 'core_people', 'people'

    execute 'ALTER TABLE core.people DROP CONSTRAINT people_pkey CASCADE'
    rename_column 'core.people', 'id', 'id_old'
    rename_column 'core.people', 'uuid', 'id'
    #add_column 'core.people', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.people', :id_old
    execute 'ALTER TABLE core.people ADD CONSTRAINT people_pkey PRIMARY KEY (id)'

    fk_to_uuid('core_person_credentials', 'person_id', 'core.people')
    fk_to_uuid('core.group_members', 'person_id', 'core.people')
    fk_to_uuid('core_sessions', 'auth_person_id', 'core.people')
    fk_to_uuid('core.log_entries', 'person_id', 'core.people')
    fk_to_uuid('core.notifications', 'person_id', 'core.people')
    fk_to_uuid('core.organization_people', 'person_id', 'core.people')
    fk_to_uuid('core.organizations_acl', 'person_id', 'core.people')
    fk_to_uuid('core_people_acl', 'obj_id', 'core.people')
    fk_to_uuid('core_people_acl', 'person_id', 'core.people')
    fk_to_uuid('core_person_roles', 'person_id', 'core.people')
    fk_to_uuid('core_person_contacts', 'person_id', 'core.people')
    fk_to_uuid('ml.msgs', 'person_id', 'core.people')

    # People ACL
    execute "ALTER TABLE core_people_acl SET SCHEMA core"
    rename_table 'core_people_acl', 'people_acl'

    # Person Contact
    execute "ALTER TABLE core_person_contacts SET SCHEMA core"
    rename_table 'core_person_contacts', 'person_contacts'

    execute 'ALTER TABLE core.person_contacts DROP CONSTRAINT person_contacts_pkey CASCADE'
    rename_column 'core.person_contacts', 'id', 'id_old'
    rename_column 'core.person_contacts', 'uuid', 'id'
    #add_column 'core.person_contacts', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.person_contacts', :id_old
    execute 'ALTER TABLE core.person_contacts ADD CONSTRAINT person_contacts_pkey PRIMARY KEY (id)'

    # Person Credential
    execute "ALTER TABLE core_person_credentials SET SCHEMA core"
    execute 'ALTER TABLE core_person_credentials DROP CONSTRAINT core_credentials_pkey CASCADE'
    rename_table 'core_person_credentials', 'person_credentials'
    rename_column 'core.person_credentials', 'id', 'id_old'
    rename_column 'core.person_credentials', 'uuid', 'id'
    #add_column 'core.person_credentials', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.person_credentials', :id_old
    execute 'ALTER TABLE core.person_credentials ADD CONSTRAINT person_credentials_pkey PRIMARY KEY (id)'

    fk_to_uuid('core_sessions', 'auth_credential_id', 'core.person_credentials')

    # Person Role
    execute "ALTER TABLE core_person_roles SET SCHEMA core"
    execute 'ALTER TABLE core_person_roles DROP CONSTRAINT core_identity_capabilities_pkey CASCADE'
    rename_table 'core_person_roles', 'person_roles'
    rename_column 'core.person_roles', 'id', 'id_old'
    add_column 'core.person_roles', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.person_roles', :id_old
    execute 'ALTER TABLE core.person_roles ADD CONSTRAINT person_roles_pkey PRIMARY KEY (id)'

    # Replicas
    execute "ALTER TABLE core_replicas SET SCHEMA core"
    rename_table 'core_replicas', 'replicas'

    execute 'ALTER TABLE core.replicas DROP CONSTRAINT replicas_pkey CASCADE'
    rename_column 'core.replicas', 'id', 'id_old'
    rename_column 'core.replicas', 'uuid', 'id'
    #add_column 'core.replicas', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.replicas', :id_old
    execute 'ALTER TABLE core.replicas ADD CONSTRAINT replicas_pkey PRIMARY KEY (id)'

    # Replica Notiy
    execute "ALTER TABLE core_replica_notifies SET SCHEMA core"
    rename_table 'core_replica_notifies', 'replica_notifies'

    execute 'ALTER TABLE core.replica_notifies DROP CONSTRAINT replica_notifies_pkey CASCADE'
    rename_column 'core.replica_notifies', 'id', 'id_old'
    rename_column 'core.replica_notifies', 'uuid', 'id'
    add_index 'core.replica_notifies', :id_old
    execute 'ALTER TABLE core.replica_notifies ADD CONSTRAINT replica_notifies_pkey PRIMARY KEY (id)'

    rename_column 'core.replica_notifies', 'obj_id', 'obj_id_old'
    add_column 'core.replica_notifies', 'obj_id', 'uuid'
    rename_column 'core.replica_notifies', 'notify_obj_id', 'notify_obj_id_old'
    add_column 'core.replica_notifies', 'notify_obj_id', 'uuid'

    # Session
    execute "ALTER TABLE core_sessions SET SCHEMA core"
    execute 'ALTER TABLE core_sessions DROP CONSTRAINT core_http_sessions_pkey CASCADE'
    rename_table 'core_sessions', 'sessions'
    rename_column 'core.sessions', 'id', 'id_old'
    rename_column 'core.sessions', 'uuid', 'id'
    #add_column 'core.sessions', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.sessions', :id_old
    execute 'ALTER TABLE core.sessions ADD CONSTRAINT sessions_pkey PRIMARY KEY (id)'

    fk_to_uuid('core.log_entries', 'http_session_id', 'core.sessions')

    # Task
    execute "ALTER TABLE core_tasks SET SCHEMA core"
    execute 'ALTER TABLE core_tasks DROP CONSTRAINT core_provisioning_requests_pkey CASCADE'
    rename_table 'core_tasks', 'tasks'
    rename_column 'core.tasks', 'id', 'id_old'
    rename_column 'core.tasks', 'uuid', 'id'
    #add_column 'core.tasks', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.tasks', :id_old
    execute 'ALTER TABLE core.tasks ADD CONSTRAINT tasks_pkey PRIMARY KEY (id)'

    remove_index 'core.tasks', column: [ :depends_on_id ], name: 'core_provisioning_requests_depends'

    fk_to_uuid('core_task_notifies', 'task_id', 'core.tasks')
    fk_to_uuid('core.tasks', 'depends_on_id', 'core.tasks')

    rename_column 'core.tasks', 'obj_id', 'obj_id_old'
    add_column 'core.tasks', 'obj_id', 'uuid'


    # Task notify
    execute "ALTER TABLE core_task_notifies SET SCHEMA core"
    rename_table 'core_task_notifies', 'task_notifies'

    execute 'ALTER TABLE core.task_notifies DROP CONSTRAINT task_notifies_pkey CASCADE'
    rename_column 'core.task_notifies', 'id', 'id_old'
    add_column 'core.task_notifies', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.task_notifies', :id_old
    execute 'ALTER TABLE core.task_notifies ADD CONSTRAINT task_notifies_pkey PRIMARY KEY (id)'

    rename_column 'core.task_notifies', 'obj_id', 'obj_id_old'
    add_column 'core.task_notifies', 'obj_id', 'uuid'

    # Groups
    execute "ALTER TABLE core_groups SET SCHEMA core"
    rename_table 'core_groups', 'groups'

    execute 'ALTER TABLE core.groups DROP CONSTRAINT groups_pkey CASCADE'
    rename_column 'core.groups', 'id', 'id_old'
    add_column 'core.groups', 'id', 'uuid', default: lambda { 'gen_random_uuid()' }, null: false
    add_index 'core.groups', :id_old
    execute 'ALTER TABLE core.groups ADD CONSTRAINT groups_pkey PRIMARY KEY (id)'

    fk_to_uuid('core.group_members', 'group_id', 'core.groups')
    fk_to_uuid('core.organizations_acl', 'group_id', 'core.groups')
    fk_to_uuid('core.people_acl', 'group_id', 'core.groups')
    fk_to_uuid('core.organizations', 'admin_group_id', 'core.groups')

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
