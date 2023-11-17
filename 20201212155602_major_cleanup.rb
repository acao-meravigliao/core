class MajorCleanup < ActiveRecord::Migration[6.0]
  def change
    remove_column 'core.agents', 'id_old'
    remove_column 'core.organizations', 'id_old'
    remove_column 'core.organizations', 'old_birth_location_id'
    remove_column 'core.organizations', 'old_src_id'
    remove_column 'core.organizations', 'old_first_name'
    remove_column 'core.organizations', 'old_last_name'
    remove_column 'core.organizations', 'old_gender'
    remove_column 'core.organizations', 'old_birth_date'
    remove_column 'core.organizations', 'headquarters_location_id_old'
    remove_column 'core.organizations', 'registered_office_location_id_old'
    remove_column 'core.organizations', 'invoicing_location_id_old'
    remove_column 'core.organizations', 'admin_group_id_old'
    remove_column 'core.notifications', 'person_id_old'
    remove_column 'core.notifications', 'obj_id_old'
    remove_column 'core.organization_people', 'organization_id_old'
    remove_column 'core.organization_people', 'person_id_old'
    remove_column 'core.people', 'id_old'
    remove_column 'core.people', 'residence_location_id_old'
    remove_column 'core.people', 'birth_location_id_old'
    remove_column 'core.people', 'invoicing_location_id_old'
    remove_column 'core.people', 'preferred_language_id_old'
    remove_column 'core.person_contacts', 'person_id_old'
    remove_column 'core.person_credentials', 'id_old'
    remove_column 'core.person_credentials', 'person_id_old'
    remove_column 'core.global_roles', 'id_old'
    remove_column 'core.person_roles', 'id_old'
    remove_column 'core.person_roles', 'identity_id'
    remove_column 'core.person_roles', 'global_role_id_old'
    remove_column 'core.person_roles', 'person_id_old'
    remove_column 'core.replica_notifies', 'obj_id_old'
    remove_column 'core.replica_notifies', 'notify_obj_id_old'
    remove_column 'core.replicas', 'obj_id_old'
    remove_column 'core.replicas', 'id_old'
    remove_column 'core.sessions', 'id_old'
    remove_column 'core.sessions', 'auth_credential_id_old'
    remove_column 'core.sessions', 'auth_identity_id'
    remove_column 'core.sessions', 'auth_person_id_old'
    remove_column 'core.sessions', 'language_id_old'
    remove_column 'core.task_notifies', 'task_id_old'
    remove_column 'core.tasks', 'id_old'
    remove_column 'core.tasks', 'obj_id_old'
    remove_column 'core.tasks', 'depends_on_id_old'
    remove_column 'core.group_members', 'id_old'
    remove_column 'core.group_members', 'identity_id'
    remove_column 'core.group_members', 'group_id_old'
    remove_column 'core.group_members', 'person_id_old'
    remove_column 'core.groups', 'id_old'
    remove_column 'core.locations', 'id_old'
    remove_column 'core.klass_collection_role_defs', 'id_old'
    remove_column 'core.klass_collection_role_defs', 'uuid'
    remove_column 'core.klass_collection_role_defs', 'klass_id_old'
    remove_column 'core.klass_members_role_defs', 'id_old'
    remove_column 'core.klass_members_role_defs', 'klass_id_old'
    remove_column 'core.klasses', 'id_old'
    remove_column 'core.log_entries', 'id_old'
    remove_column 'core.log_entries', 'person_id_old'
    remove_column 'core.log_entries', 'http_session_id_old'
    remove_column 'core.log_entry_details', 'id_old'
    remove_column 'core.log_entry_details', 'log_entry_id_old'
    remove_column 'core.log_entry_details', 'obj_id_old'
    remove_column 'core.organization_people', 'id_old'
    remove_column 'core.person_contacts', 'id_old'
    remove_column 'core.replica_notifies', 'id_old'
    remove_column 'core.task_notifies', 'id_old'
    remove_column 'core.task_notifies', 'obj_id_old'

    remove_column 'ca.cas', 'id_old'
    remove_column 'ca.cas', 'key_pair_id_old'
    remove_column 'ca.cas', 'certificate_id_old'
    remove_column 'ca.certificate_altnames', 'certificate_id_old'
    remove_column 'ca.certificates', 'id_old'
    remove_column 'ca.certificates', 'key_pair_id_old'
    remove_column 'ca.key_pair_locations', 'id_old'
    remove_column 'ca.key_pair_locations', 'pair_id_old'
    remove_column 'ca.key_pair_locations', 'store_id_old'
    remove_column 'ca.key_pairs', 'id_old'
    remove_column 'ca.key_stores', 'id_old'
    remove_column 'ca.key_stores', 'remote_agent_id_old'
    remove_column 'ca.le_accounts', 'id_old'
    remove_column 'ca.le_accounts', 'key_pair_id_old'
    remove_column 'ca.le_order_auth_challenges', 'id_old'
    remove_column 'ca.le_order_auth_challenges', 'order_auth_id_old'
    remove_column 'ca.le_order_auths', 'id_old'
    remove_column 'ca.le_order_auths', 'order_id_old'
    remove_column 'ca.le_orders', 'id_old'
    remove_column 'ca.le_orders', 'account_id_old'
    remove_column 'ca.le_orders', 'certificate_id_old'
    remove_column 'ca.le_orders', 'slot_id_old'
    remove_column 'ca.le_slots', 'id_old'
    remove_column 'ca.le_slots', 'account_id_old'
    remove_column 'ca.le_slots', 'key_store_id_old'
    remove_column 'ca.le_slots', 'certificate_id_old'
    remove_column 'ca.le_slots', 'owner_id_old'

    remove_column 'i18n.translations', 'phrase_id_old'
    remove_column 'i18n.translations', 'language_id_old'
    remove_column 'i18n.languages', 'id_old'
    remove_column 'i18n.phrases', 'id_old'
    remove_column 'i18n.translations', 'id_old'

    remove_column 'ml.addresses', 'id_old'
    remove_column 'ml.list_members', 'address_id_old'
    remove_column 'ml.list_members', 'list_id_old'
    remove_column 'ml.list_members', 'owner_id_old'
    remove_column 'ml.lists', 'id_old'
    remove_column 'ml.msg_bounces', 'id_old'
    remove_column 'ml.msg_bounces', 'msg_id_old'
    remove_column 'ml.msg_events', 'msg_id_old'
    remove_column 'ml.msg_lists', 'id_old'
    remove_column 'ml.msg_lists', 'msg_id_old'
    remove_column 'ml.msg_lists', 'list_id_old'
    remove_column 'ml.msg_objects', 'id_old'
    remove_column 'ml.msg_objects', 'msg_id_old'
    remove_column 'ml.msg_objects', 'object_id_old'

    execute 'DELETE FROM ml.msg_objects WHERE object_id IS NULL'

    change_column_null 'ml.msg_objects', 'object_id', false
    remove_column 'ml.msgs', 'id_old'
    remove_column 'ml.msgs', 'sender_id_old'
    remove_column 'ml.msgs', 'person_id_old'
    remove_column 'ml.msgs', 'recipient_id_old'
    remove_column 'ml.senders', 'id_old'
    remove_column 'ml.senders', 'email_dkim_key_pair_id_old'
    remove_column 'ml.templates', 'id_old'
    remove_column 'ml.templates', 'language_id_old'
  end
end