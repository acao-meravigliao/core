#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'openssl'

module Ygg
module Ca

class KeyStore::Local < KeyStore
  def pairs_hashes
    Dir.new(local_directory).map { |x| x =~ /([a-z0-9]{40})\.key$/ ? $1 : nil }.select { |x| x }
  end

  def pairs
    pairs_hashes.map { |x| pair(x) }
  end

  def pair(hash)
    LocalKeyPair.new_from_file(store: self, file: File.join(local_directory, "#{hash}.key"))
  end

  def generate_pair(key_type: 'RSA', key_length: 2048)
    raise ProcessError, "Key type #{key_type} not supported" if key_type != 'RSA'

    newkey = LocalKeyPair.generate(store: self, key_length: key_length)

    newkey.file = File.join(local_directory, "#{newkey.public_key_hash}.key")

    File.open(newkey.file, File::RDWR|File::CREAT, 0440) do |f|
     f.write newkey.ossl_key_pair.to_pem
    end

    sync_pairs_with_models!

    newkey
  end

  def import(key_file:)
    newkey = LocalKeyPair.new_from_key(store: self, key: OpenSSL::PKey::RSA.new(File.read(key_file)))
    newkey.file = File.join(local_directory, "#{newkey.public_key_hash}.key")

    File.open(newkey.file, File::RDWR|File::CREAT, 0440) do |f|
     f.write newkey.ossl_key_pair.to_pem
    end

    sync_pairs_with_models!

    newkey
  end

  def sync_pairs_with_models!
    pairs.each { |x| x.sync_with_model! }
  end


  class LocalKeyPair
    attr_accessor :store
    attr_accessor :key_type
    attr_accessor :key_length
    attr_accessor :ossl_key_pair
    attr_accessor :public_key
    attr_accessor :public_key_hash
    attr_accessor :file

    def initialize(**args)
      args.each { |k,v| send("#{k}=", v) }
    end

    def self.new_from_file(store:, file:)
      pair = new_from_key(store: store, key: OpenSSL::PKey::RSA.new(File.read(file)))
      pair.file = file
      pair
    end

    def self.new_from_key(store:, key:)
      pair = new(store: store, key_type: 'RSA')
      pair.ossl_key_pair = key
      pair.public_key = key.public_key.to_s
      pair.public_key_hash = Digest::SHA1.hexdigest(key.public_key.to_der.to_s)
      pair.key_length = key.n.num_bytes * 8

      pair
    end

    def self.generate(store:, key_length: 2048)
      new_from_key(store: store, key: OpenSSL::PKey::RSA.generate(key_length))
    end

    def private_key
      ossl_key_pair
    end

    def public_key
      ossl_key_pair.public_key
    end

    def created_at
      File.ctime(file)
    end

    def sync_with_model!
      kp = Ygg::Ca::KeyPair.find_by(public_key_hash: public_key_hash)
      if !kp
        kp = Ygg::Ca::KeyPair.create(
          key_type: key_type,
          key_length: key_length,
          public_key: public_key,
          created_at: created_at,
        )
      end

      kp.locations.find_or_create_by(store: store, identifier: public_key_hash)
      kp.save!

      kp
    end
  end
end

end
end
