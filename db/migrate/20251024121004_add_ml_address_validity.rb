class AddMlAddressValidity < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'ml', 'public'"

    add_column 'addresses', 'validated', :boolean, null: false, default: false
    add_column 'addresses', 'validated_at', :timestamp
    add_column 'addresses', 'reliable', :boolean, null: false, default: true
    add_column 'addresses', 'reliability_score', :integer, null: false, default: 100

    create_table 'address_validation_tokens', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :address_id, null: false
      t.string :code, null: false
      t.timestamp :created_at
      t.timestamp :expires_at
      t.timestamp :used_at
      t.string "http_remote_addr", limit: 42
      t.integer "http_remote_port"
      t.text "http_x_forwarded_for"
      t.text "http_via"
      t.string "http_server_addr", limit: 42
      t.integer "http_server_port"
      t.string "http_server_name", limit: 64
      t.text "http_referer"
      t.text "http_user_agent"
      t.text "http_request_uri"
    end

    add_index 'address_validation_tokens', [ :code ], unique: true
    add_index 'address_validation_tokens', [ :address_id ]

    add_foreign_key 'address_validation_tokens', 'addresses', column: 'address_id', on_delete: :cascade

    Ygg::Ml::Address.update_all(validated: true, validated_at: Time.now)

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    remove_column 'ml.addresses', 'validated'
    remove_column 'ml.addresses', 'reliable'
    remove_column 'ml.addresses', 'reliability_score'
    drop_table 'ml.address_validation_tokens'
  end
end
