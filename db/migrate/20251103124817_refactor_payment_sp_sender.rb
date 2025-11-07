class RefactorPaymentSpSender < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'satispay_entities', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.string :type
      t.string :name
    end

    create_table 'satispay_profile_pictures', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid 'entity_id', null: false
      t.string 'source', null: false
      t.integer :width
      t.integer :height
      t.boolean :is_original
      t.string :url
    end

    add_index 'satispay_profile_pictures', [ :entity_id ]

    add_foreign_key 'satispay_profile_pictures', 'satispay_entities', column: 'entity_id', on_delete: :cascade

    change_column 'acao.payments', 'sp_sender_id', :uuid, using: 'sp_sender_id::uuid'
    change_column 'acao.payments', 'sp_receiver_id', :uuid, using: 'sp_receiver_id::uuid'

    add_index 'payments', [ :sp_sender_id ]
    add_index 'payments', [ :sp_receiver_id ]

    Ygg::Acao::Payment.all.each do |p|
      p.sp_sender = Ygg::Acao::SatispayEntity.find_or_create_by!(id: p.sp_sender_id) do |s|
        s.type = p.sp_sender_type
        s.name = p.sp_sender_name
      end

      p.sp_receiver = Ygg::Acao::SatispayEntity.find_or_create_by!(id: p.sp_receiver_id) do |s|
        s.type = p.sp_receiver_type
      end
    end

    add_foreign_key 'payments', 'satispay_entities', column: 'sp_sender_id', on_delete: :cascade
    add_foreign_key 'payments', 'satispay_entities', column: 'sp_receiver_id', on_delete: :cascade

#    remove_column 'payments', 'sp_sender_profile_picture'
#    remove_column 'payments', 'sp_status_code'
#    remove_column 'payments', 'sp_redirect_url'
    remove_column 'payments', 'sp_sender_name'
    remove_column 'payments', 'sp_sender_type'
    remove_column 'payments', 'sp_receiver_type'


    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.satispay_profile_pictures'
    drop_table 'acao.satispay_entities'
  end
end
