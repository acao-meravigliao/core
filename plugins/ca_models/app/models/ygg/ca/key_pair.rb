#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyPair < Ygg::PublicModel
  self.table_name = 'ca.key_pairs'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "key_type", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "key_length", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "descr", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "public_key_hash", type: :string, default: nil, limit: 64, null: false}],
    [ :must_have_column, {name: "public_key", type: :text, default: nil, null: false}],

    [ :must_have_index, {columns: ["public_key_hash"], unique: true}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  has_many :locations,
           class_name: 'Ygg::Ca::KeyPair::Location',
           foreign_key: 'pair_id',
           embedded: true,
           autosave: true,
           dependent: :destroy

  has_many :certificates,
           class_name: 'Ygg::Ca::Certificate'

  after_create :associate_certificates

  def associate_certificates
    Ygg::Ca::Certificate.all.each do |x|
      if x.public_key_hash == public_key_hash
        x.key_pair = self
        x.save!
      end
    end
  end

  def public_key=(public_key)
    if !public_key
      write_attribute(:public_key, nil)
      return
    end

    public_key = OpenSSL::PKey::RSA.new(public_key) if !public_key.kind_of? OpenSSL::PKey::RSA
    self.public_key_hash = Digest::SHA1.hexdigest(public_key.to_der)

    write_attribute(:public_key, public_key.to_pem)
  end

  def public_key_in_dkim_format
    public_key.lines[1..-2].map(&:chop).join
  end

#  def manually_update_hash!
#    self.public_key = retrieve_public_key
#    save!
#  end

  def summary
    "#{key_type}-#{key_length.to_s} #{public_key_hash}"
  end
end

end
end
