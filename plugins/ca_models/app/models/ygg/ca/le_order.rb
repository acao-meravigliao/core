#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class LeOrder < Ygg::PublicModel
  self.table_name = 'ca.le_orders'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :integer, null: false } ],
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "not_before", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "not_after", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "expires", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "finalize_url", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "account_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "url", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "csr", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "certificate_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "certificate_url", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "created_at", type: :datetime, default: nil, null: true}],

    [ :must_have_index, {columns: ["account_id"], unique: false}],
    [ :must_have_index, {columns: ["certificate_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_le_accounts", column: "account_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "ca_certificates", column: "certificate_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  belongs_to :account,
             class_name: 'Ygg::Ca::LeAccount'

  belongs_to :slot,
             class_name: 'Ygg::Ca::LeSlot',
             optional: true

  has_many :auths,
           foreign_key: :order_id,
           class_name: 'Ygg::Ca::LeOrder::Auth',
           inverse_of: :order, # Rails bug https://github.com/rails/rails/issues/25198
           embedded: true,
           autosave: true,
           dependent: :destroy

  belongs_to :certificate,
             class_name: 'Ygg::Ca::Certificate',
             optional: true

  def self.new_from_acme(account:, identifiers:, not_before: Time.now, not_after: Time.now + 1.year, **args)
    account.init_client # Needed for directory

    resp = account.generic_request(
      uri: account.directory['newOrder'],
      payload: {
        identifiers: identifiers.map { |x| { type: 'dns', value: x } },
#        notBefore: not_before,
#        notAfter: not_after,
      },
    )

    body = JSON.parse(resp.body)

    order = find_by(url: resp.headers['Location'])
    if !order
      order = new(
        created_at: Time.now,
        url: resp.headers['Location'],
        account: account,
        auths: body['authorizations'].map { |x| LeOrder::Auth.new(url: x) },
        **args
      )

      order.save!
    end

    order.update_from_acme(body)
    order.sync_auths_from_acme

    order
  end

  def self.p_account(account)
    Ygg::Ca::LeAccount.persistent(account.symbol)
  end

  def p_account
    self.class.p_account(account)
  end

  def sync_from_acme!
    resp = p_account.generic_get_request(uri: url)

    body = JSON.parse(resp.body)

    update_from_acme(body)
  end

  def sync_auths_from_acme
    auths.each do |auth|
      auth.sync_from_acme!
    rescue Ygg::Ca::LeOrder::Auth::NotFound => e
    end
  end

  def update_from_acme(body)
    transaction do
      update!(
        not_before: body['notBefore'],
        not_after: body['notAfter'],
        status: body['status'],
        finalize_url: body['finalize'],
        certificate_url: body['certificate'],
        expires: Time.parse(body['expires']),
      )
    end
  end

  class PermanentFailure < StandardError ; end

  def each_challenge
    auths.each do |auth|
      auth.challenges.each do |challenge|
        yield auth, challenge
      end
    end
  end

  def fulfill_challenges
    auths.each do |auth|
      auth.sync_from_acme!

      if auth.status == 'pending'
        auth.challenges.each do |challenge|
          case challenge.type
          when 'dns-01'
            if challenge.started_at.nil?
              challenge.start_local_tasks!
            end
          end
        end
      end
    end
  end

  def process
    if expires < Time.now
      self.status = 'expired'
      save!
      return
    end

    return if certificate

    begin
      sync_from_acme!
    rescue Ygg::Ca::LeAccount::RequestProblem => e
      if e.cause.status_code == 404
        self.status = 'expired'
        save!
        return
      end
    else
      do_process
    end
  end

  def do_process
    case status
    when 'pending'
      fulfill_challenges

    when 'ready'
      resp = p_account.generic_request(
        uri: finalize_url,
        payload: {
          csr: Base64.urlsafe_encode64(OpenSSL::X509::Request.new(csr).to_der),
        }
      )

      body = JSON.parse(resp.body)
      update_from_acme(body)

      if status == 'valid'
        do_process
      end

    when 'processing'

    when 'valid'
      certs = download_certificates
      self.certificate = certs[0]
      save!

      if slot
        slot.new_certificate_generated(certs[0])
      end

    when 'invalid'
    end
  end

  def download_certificates
    resp = p_account.generic_get_request(uri: certificate_url)

    if resp.headers['Content-type'] != 'application/pkix-cert' &&
       resp.headers['Content-type'] != 'application/pem-certificate-chain'
      raise "Unexpected content type #{resp.headers['Content-type']}"
    end

    certs = resp.body.scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m).map do |cert|
      Ygg::Ca::Certificate.create(pem: OpenSSL::X509::Certificate.new(resp.body).to_pem)
    end

    certs
  end

  def self.run_chores
    all.where(certificate: nil).where.not(status: [ 'invalid', 'expired' ]).each do |order|
      order.run_chores
    end
  end

  def run_chores
    process
  end
end

end
end
