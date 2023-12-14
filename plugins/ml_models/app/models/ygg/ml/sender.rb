#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Sender < Ygg::PublicModel
  self.table_name = 'ml.senders'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "descr", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "email_address", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "email_signing_key_filename", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "email_signing_cert_filename", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "email_bounces_domain", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "email_reply_to", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "email_organization", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "email_smtp_pars", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "email_dkim_selector", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "email_dkim_key_pair_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "skebby_username", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "skebby_password", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "skebby_sender_number", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "skebby_sender_string", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "skebby_token", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "skebby_user_key", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["symbol"], unique: true}],
    [ :must_have_index, {columns: ["email_dkim_key_pair_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca.key_pairs", column: "email_dkim_key_pair_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :email_dkim_key_pair,
             class_name: 'Ygg::Ca::KeyPair',
             optional: true

  has_many :messages,
           class_name: 'Ygg::Ml::Msg'

  serialize :email_smtp_pars, JSON

  def email_domain
    ::Mail::Address.new(email_address).domain
  end

  def email_dkim_key_pair
    super || email_lookup_dkim_key
  end

  def email_lookup_dkim_key
    begin ; Ygg::Email::Domain ; rescue NameError ; return nil ; end

    domain = Ygg::Email::Domain.find_by(name: email_domain)
    return nil if !domain

    domain.domain_dkim_key_pairs.joins(:key_pair).order('key_pairs.created_at': 'DESC').where(selector: email_dkim_selector).first.key_pair
  end

  def email_signing_key
    email_signing_key_filename && OpenSSL::PKey::RSA.new(File.read(email_signing_key_filename))
  end

  def email_signing_chain
    return nil if !email_signing_cert_filename

    File.read(email_signing_cert_filename).
      scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m).
      map { |x| OpenSSL::X509::Certificate.new(x) }
  end

  def can_smime_sign?
    email_signing_key && email_signing_chain
  end
end

end
end
