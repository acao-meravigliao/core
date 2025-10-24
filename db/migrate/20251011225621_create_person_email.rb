class CreatePersonEmail < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'core', 'public'"

    create_table 'person_emails', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid :person_id, null: false
      t.string :email, null: false
      t.uuid :ml_address_id
    end

    add_index 'person_emails', [ :person_id, :email ]
    add_index 'person_emails', [ :person_id ]

    add_foreign_key 'person_emails', 'people', column: 'person_id', on_delete: :cascade

    Ygg::Core::Person::Contact.where(type: 'email').each do |contact|
      Ygg::Core::Person::Email.create!(
        person_id: contact.person_id,
        email: contact.value,
        ml_address: Ygg::Ml::Address.find_or_create_by(addr: contact.value) { |mail| mail.name = contact.person.name }
      )
    end

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.person_emails'
  end
end
