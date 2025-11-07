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

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :email_dkim_key_pair,
             class_name: 'Ygg::Ca::KeyPair',
             optional: true

  has_many :messages,
           class_name: 'Ygg::Ml::Msg'

  serialize :email_smtp_pars, coder: JSON

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
