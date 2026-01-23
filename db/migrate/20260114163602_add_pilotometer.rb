class AddPilotometer < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.members', 'wind_rating', :boolean, null: false, default: false
    add_column 'acao.members', 'wind_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'wind_lim_to', :timestamp
    add_column 'acao.members', 'wind_lim_reason', :string
    add_column 'acao.members', 'astir_rating', :boolean, null: false, default: false
    add_column 'acao.members', 'astir_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'astir_lim_to', :timestamp
    add_column 'acao.members', 'astir_lim_reason', :string
    add_column 'acao.members', 'discus_rating', :boolean, null: false, default: false
    add_column 'acao.members', 'discus_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'discus_lim_to', :timestamp
    add_column 'acao.members', 'discus_lim_reason', :string
    add_column 'acao.members', 'duodiscus_rating', :boolean, null: false, default: false
    add_column 'acao.members', 'duodiscus_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'duodiscus_lim_to', :timestamp
    add_column 'acao.members', 'duodiscus_lim_reason', :string
    add_column 'acao.members', 'solo_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'solo_lim_to', :timestamp
    add_column 'acao.members', 'solo_lim_reason', :string
    add_column 'acao.members', 'pax_lim', :boolean, null: false, default: false
    add_column 'acao.members', 'pax_lim_to', :timestamp
    add_column 'acao.members', 'pax_lim_reason', :string

    create_table 'acao.member_pm_notes', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :member_id, null: false
      t.uuid :author_id, null: false
      t.string :cls, null: false, limit: 16
      t.string :text
      t.timestamps
    end

    add_index 'acao.member_pm_notes', [ :member_id ]
    add_index 'acao.member_pm_notes', [ :author_id ]

    add_foreign_key 'acao.member_pm_notes', 'acao.members', column: 'member_id', on_delete: :cascade
    add_foreign_key 'acao.member_pm_notes', 'acao.members', column: 'author_id', on_delete: :cascade

    Ygg::Acao::Member.update_all(wind_rating: true, duodiscus_rating: true, discus_rating: true, astir_rating: true, solo_rating: true)
  end
end
