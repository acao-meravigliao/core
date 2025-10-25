class AddPrivacyToMember < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.members', 'email_allowed_at', :timestamp
    add_column 'acao.members', 'privacy_accepted', :boolean, default: false
    add_column 'acao.members', 'privacy_accepted_at', :timestamp
    add_column 'acao.members', 'consent_association', :boolean, default: false
    add_column 'acao.members', 'consent_surveillance', :boolean, default: false
    add_column 'acao.members', 'consent_accessory', :boolean, default: false
    add_column 'acao.members', 'consent_profiling', :boolean, default: false
    add_column 'acao.members', 'consent_magazine', :boolean, default: false
    add_column 'acao.members', 'consent_fai', :boolean, default: false
    add_column 'acao.members', 'consent_marketing', :boolean, default: false
    add_column 'acao.members', 'consent_members', :boolean, default: false

    Ygg::Acao::Member.update_all(privacy_accepted: true)
  end
end
