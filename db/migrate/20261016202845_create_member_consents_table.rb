class CreateMemberConsentsTable < ActiveRecord::Migration[8.1]
  def change
    create_table 'acao.member_consents', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.timestamps
      t.uuid :member_id, null: false
      t.timestamp :at
      t.boolean :consent_association
      t.boolean :consent_surveillance
      t.boolean :consent_accessory
      t.boolean :consent_profiling
      t.boolean :consent_magazine
      t.boolean :consent_fai
      t.boolean :consent_marketing
      t.boolean :consent_members
    end

    add_index 'acao.member_consents', [ :member_id ]
    add_index 'acao.member_consents', [ :at ]

    add_foreign_key 'acao.member_consents', 'acao.members', column: 'member_id', on_delete: :cascade

    Ygg::Acao::Member.where(privacy_accepted: true).each do |m|
      m.consents.create(
        at: m.privacy_accepted_at,
        consent_association:  m.consent_association,
        consent_surveillance: m.consent_surveillance,
        consent_accessory:    m.consent_accessory,
        consent_profiling:    m.consent_profiling,
        consent_magazine:     m.consent_magazine,
        consent_fai:          m.consent_fai,
        consent_marketing:    m.consent_marketing,
        consent_members:      m.consent_members,
      )
    end

  end
end
