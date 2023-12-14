#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyStore::Remote < KeyStore
  belongs_to :remote_agent,
             class_name: '::Ygg::Core::Agent',
             optional: true

  def pairs(path:)
    keys = rpc(operation: 'ks_list_pairs', data: { path: path })

    res = keys.map do |k,key|
      RemoteKeyPair.new(
        store: self,
        path: path,
        key_type: key[:key_type],
        key_length: key[:key_length],
        public_key: key[:public_key],
        public_key_hash: key[:public_key_hash],
        created_at: key[:created_at],
      )
    end

    res
  end

  def pair(path:, hash:)
    pairs(path: path).find { |x| x.public_key_hash == hash }
  end

  def generate_pair(path: id, key_type: 'RSA', key_length: 2048)
    res = rpc(operation: 'ks_generate_pair', data: { path: path, key_type: key_type, key_length: key_length })

    sync_pairs_with_models!(path: path)

    key = res[:new_pair]

#    Ygg::Ca::KeyPair.find_by(public_key_hash: res[:new_pair][:public_key_hash])

    RemoteKeyPair.new(
      store: self,
      path: path,
      key_type: key[:key_type],
      key_length: key[:key_length],
      public_key: key[:public_key],
      public_key_hash: key[:public_key_hash],
      created_at: key[:created_at],
    )
  end

  def sync_pairs_with_models!(path:)
    pairs(path: path).each { |x| x.sync_with_model!(path: path) }
  end

  def rpc(**args)
    remote_agent.rpc(**args)
  end

  class RemoteKeyPair
    attr_accessor :store
    attr_accessor :path
    attr_accessor :key_type
    attr_accessor :key_length
    attr_accessor :public_key
    attr_accessor :public_key_hash
    attr_accessor :created_at

    def initialize(**args)
      args.each { |k,v| send("#{k}=", v) }
    end

    def generate_csr(attrs:)
      store.rpc(operation: 'ks_generate_csr', data: { path: path, identifier: public_key_hash, attrs: attrs })
    end

    def sync_with_model!(path: nil)
      kp = Ygg::Ca::KeyPair.find_by(public_key_hash: public_key_hash)
      if !kp
        kp = Ygg::Ca::KeyPair.create(
          key_type: key_type,
          key_length: key_length,
          public_key: public_key,
          created_at: created_at,
        )
      end

      kp.locations.find_or_create_by(store: store, path: path, identifier: public_key_hash)
      kp.save!

      kp
    end
  end
end

end
end
