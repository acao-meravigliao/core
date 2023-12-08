#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'fileutils'

require 'openssl'
require 'json/jwt'

require 'am/http/client'

module Ygg
module Ca

class LeAccount < Ygg::PublicModel
  self.table_name = 'ca.le_accounts'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: true}],
    [ :must_have_column, {name: "key_pair_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "email_contact", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "endpoint", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "account_url", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["key_pair_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_key_pairs", column: "key_pair_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  has_many :le_orders,
           class_name: '::Ygg::Ca::LeOrder',
           inverse_of: :le_account # Rails bug https://github.com/rails/rails/issues/25198

  belongs_to :key_pair,
             class_name: '::Ygg::Ca::KeyPair'

  attr_reader :directory
  attr_reader :jwk
  attr_reader :meta_tos_link
  attr_reader :reg_data

  attr_reader :acme_id
  attr_reader :acme_status
  attr_reader :acme_created_at
  attr_reader :acme_initial_ip

  def self.http_client
    @http_client ||= AM::HTTP::Client.new(debug: Rails.application.config.ca.le_http_debug)
  end

  def self.persistent(symbol)
    @account_cache ||= {}

    if !@account_cache[symbol]
      @account_cache[symbol] = self.find_by!(symbol: symbol)
      @account_cache[symbol].init_crypto
    end

    @account_cache[symbol]
  end

  def init_crypto
    location = key_pair.locations.find { |x| x.store && x.store.symbol == 'YGGDRA' }
    raise "No keypair found in YGGDRA keystore" if !location

    keystore = location.store
    local_keypair = keystore.pair(location.identifier)

    @private_key = local_keypair.ossl_key_pair
    @public_key = @private_key.public_key
    @jwk = JSON::JWK.new(@public_key)
  end

  def init_client
    return if @client_initialized

    @http = self.class.http_client
    @nonces = []

    logger.debug "Retrieving directory"

    resp = @http.get(endpoint,
      headers: {
        'User-Agent': 'Yggdra/2.0',
        'Accept': 'application/json',
        'Accept-Language': 'en',
      },
    )

    eventually_push_nonce(resp: resp)

    @directory = JSON.parse(resp.body)

    logger.debug "Directory retrieved: #{@directory.inspect}"

    @meta_tos_link = @directory['meta']['terms-of-service']

    @client_initialized = true

    reg_check
  end

  def eventually_push_nonce(resp:)
    h = resp.headers['Replay-Nonce']
    @nonces << h if h
  end

  def pop_nonce
    @nonces.shift
  end

  def nonce_clear
    @nonces = []
  end

  class RequestProblem < StandardError
    attr_accessor :resp

    def initialize(resp:)
      @resp = resp
      super(resp.inspect)
    end
  end

  def generic_request(uri:, payload:, suppress_log: false, use_jwk: false)
    logger.info "LE request to #{uri} payload=#{payload}"

    init_client

    resp = nil

    3.times do
      nonce = pop_nonce
      if !nonce
        logger.debug "No nonce available, pulling one"

        resp = @http.head(@directory['newNonce'])
        eventually_push_nonce(resp: resp)
        nonce = pop_nonce
      end

      raise "No nonces available" if !nonce


      # Create JWS
      jwt = JSON::JWT.new(payload)
      jwt.header.merge!({
        url: uri,
        nonce: nonce,
      })

      if use_jwk
        jwt.header[:jwk] = @jwk
      else
        jwt.header[:kid] = account_url
      end

      jws = jwt.sign(@private_key, :RS256)

      resp = @http.post(uri,
        headers: {
          'User-Agent': 'Yggdra/2.0',
          'Accept': 'application/json',
          'Accept-Language': 'en',
          'Content-Type': 'application/jose+json',
        },
        body: jws.to_json(syntax: :flattened) ,
      )

      eventually_push_nonce(resp: resp)

      if resp.status_code >= 400
        if resp.headers['Content-type'] == 'application/problem+json'
          body = JSON.parse(resp.body)
          if body['type'] == 'urn:ietf:params:acme:error:badNonce' # urn:acme:error:badNonce not used anymore?
            nonce_clear
            eventually_push_nonce(resp: resp)
          else
            raise RequestProblem.new(resp: resp)
          end
        else
          raise RequestProblem.new(resp: resp)
        end
      else
        break
      end
    end

    logger.info "LE response headers=#{resp.headers} body=#{resp.body}"

    resp
  end

  def generic_get_request(uri:)
    generic_request(uri: uri, payload: nil)
  end

  def reg_check
    if !account_url
      resp = generic_request(
        uri: @directory['newAccount'],
        payload: {
          onlyReturnExisting: true,
        },
        use_jwk: true,
      )

      self.account_url = resp.headers['Location']
      save!
    end

    resp = generic_request(uri: account_url, payload: {})

    body = JSON.parse(resp.body)

    @acme_id = body['id']
    @acme_status = body['status']
    @acme_created_at = body['createdAt']
    @acme_initial_ip = body['initialIp']
  end
end

end
end
