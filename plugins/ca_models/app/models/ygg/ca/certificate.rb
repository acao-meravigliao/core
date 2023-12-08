#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class Certificate < Ygg::PublicModel
  self.table_name = 'ca.certificates'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "cn", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "email", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "pem", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "key_pair_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "valid_from", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "valid_to", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "serial", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "issuer_cn", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "subject_dn", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "issuer_dn", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "le_uri", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["issuer_dn"], unique: false}],
    [ :must_have_index, {columns: "md5(pem)", unique: true}],
    [ :must_have_index, {columns: ["subject_dn"], unique: false}],
    [ :must_have_index, {columns: ["cn"], unique: false}],
    [ :must_have_index, {columns: ["key_pair_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_key_pairs", column: "key_pair_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :key_pair,
             class_name: 'Ygg::Ca::KeyPair',
             optional: true

  has_many :alt_names,
           class_name: '::Ygg::Ca::Certificate::AltName',
           dependent: :destroy

  validates :pem, uniqueness: true

  define_default_provisionable_controller(self)

  class AltName < Ygg::BasicModel
    self.table_name = 'ca.certificate_altnames'
    self.inheritance_column = false

    self.porn_migration += [
      [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
      [ :must_have_column, {name: "certificate_id", type: :integer, default: nil, limit: 4, null: false}],
      [ :must_have_column, {name: "type", type: :string, default: nil, limit: 32, null: true}],
      [ :must_have_column, {name: "name", type: :string, default: nil, null: true}],

      [ :must_have_index, {columns: ["certificate_id"], unique: false}],
      [ :must_have_index, {columns: ["certificate_id","type","name"], unique: true, name: 'ca_certificate_altnames_ctn'}],

      [ :must_have_fk, {to_table: "ca_certificates", column: "certificate_id", primary_key: "id", on_delete: :cascade, on_update: nil}],
    ]

    belongs_to :certificate,
               class_name: '::Ygg::Ca::Certificate'
  end

  def pem=(val)
    write_attribute(:pem, val)
    @openssl_cert = nil
    update_derived_attributes
  end

  def public_key
    OpenSSL::X509::Certificate.new(pem).public_key
  end

  def public_key_hash
    Digest::SHA1.hexdigest(public_key.to_der)
  end

  def openssl_cert
    @openssl_cert ||= OpenSSL::X509::Certificate.new(pem)
  end

  def parents
    return [] if self_signed?

    self.class.where(subject_dn: issuer_dn).order(valid_to: :desc)
  end

  def chain(include_root: false)
    p = parents.to_a
    p.reject! { |x| x.self_signed? } unless include_root
    p.map! { |x| x.chain(include_root: include_root) }
    p.flatten!

    [ self ] + p
  end

  def children
    self.class.where(issuer_dn: subject_dn)
  end

  def self_signed?
    issuer_dn == subject_dn
  end

  def update_derived_attributes
    cert = openssl_cert
    self.subject_dn = cert.subject.to_s
    self.cn = cert.subject.to_a.find { |x| x[0] == 'CN' }[1]
    self.email = cert.subject.to_a.find { |x| x[0] == 'emailAddress' }.try :[], 1
    self.valid_from = cert.not_before
    self.valid_to = cert.not_after
    self.serial = cert.serial.to_s

    self.issuer_dn = cert.issuer.to_s
    self.issuer_cn = cert.issuer.to_a.find { |x| x[0] == 'CN' }[1]

    self.key_pair = Ygg::Ca::KeyPair.find_by_public_key_hash(public_key_hash)

    alt_name = cert.extensions.find { |x| x.oid == 'subjectAltName' }
    if alt_name
      self.alt_names = alt_name.value.split(',').map { |x| x.strip.match(/^(?<type>[^:]*):(?<value>.*)$/) }.
                       map { |x| Ygg::Ca::Certificate::AltName.new(type: x[:type], name: x[:value]) }
    end
  end

  def import_from_le_uri(uri:)
    account = Ygg::Ca::LeAccount.account_cache(Ygg::Ca::LeAccount.find_by(symbol: 'DEFAULT').id)

    resp = account.cert_get(uri: uri)

    self.pem = OpenSSL::X509::Certificate.new(resp.body).to_pem
  end

  public

  def summary
    cn
  end
end

end
end
