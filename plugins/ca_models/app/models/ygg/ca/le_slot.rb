#
# Copyright (C) 2018-2020, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class LeSlot < Ygg::PublicModel
  self.table_name = 'ca.le_slots'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  belongs_to :account,
             class_name: 'Ygg::Ca::LeAccount'

  belongs_to :key_store,
             class_name: 'Ygg::Ca::KeyStore'

  belongs_to :owner,
             polymorphic: true,
             optional: true

  has_many :orders,
           class_name: 'Ygg::Ca::LeOrder',
           foreign_key: 'slot_id',
           dependent: :destroy

  belongs_to :certificate,
             class_name: 'Ygg::Ca::Certificate',
             optional: true

  def create_order
    if orders.where(status: 'pending').any?
      raise "A pending order is already present"
    end

    # Find or generate a key
    ks_pairs = key_store.pairs(path: key_store_path)

    if wanted_key
      keypair = ks_pairs.find { |x| x.public_key_hash == wanted_key }
      if !keypair
        self.state = 'missing_keypair'
        save!
        raise "Missing key"
      end
    else
      keypair = key_store.generate_pair(path: key_store_path, key_type: gen_key_type, key_length: gen_key_length)
    end

    # Generate CSR
    csr = keypair.generate_csr(attrs: csr_attrs)

    identifiers = [ csr_attrs['cn'] ]
    identifiers += csr_attrs['alt_names'] if csr_attrs['alt_names']

    order = Ygg::Ca::LeOrder.new_from_acme(
      slot: self,
      account: Ygg::Ca::LeAccount.persistent('DEFAULT'),
      identifiers: identifiers,
      csr: csr,
    )

    order.process

    order.save!
  end

  def new_certificate_generated(cert)
    transaction do
      self.certificate = cert
      self.renew_at = cert.valid_to - 30.day
      save!
    end

    if owner && owner.respond_to?(:new_certificate_generated)
      owner.new_certificate_generated(cert)
    end
  end

  def self.run_chores
    all.each do |slot|
      slot.run_chores
    end
  end

  def run_chores
    if enabled &&
       (!certificate || (renew_at && renew_at < Time.now))

      # We are in need of a certficate
      valid_orders = orders.where(status: 'valid').where('expires > now()')
      if valid_orders.any?
        self.certificate = valid_orders.first.certificate
        self.renew_at = valid_orders.first.certificate.valid_to - 30.day
        save!
      elsif orders.where(status: [ 'pending', 'ready' ]).where('expires > now()').any?
        # We wait
      else
        create_order
      end
    end
  end
end

end
end
