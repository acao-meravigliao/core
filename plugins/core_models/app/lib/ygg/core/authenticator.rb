#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Authenticator
  class AuthenticationError < StandardError ; end
  class FQDAFormat < AuthenticationError ; end
  class FQDANotFound < AuthenticationError ; end
  class WrongCredentials < AuthenticationError ; end

  def self.by_fqda_and_password(fqda:, password:)
    if !fqda.is_a?(String) || !password.is_a?(String)
      raise FQDAFormat, 'FQDA is in invalid format'
    end

    unless fqda =~ /^(.*)@(.*)$/
      raise FQDAFormat, 'FQDA is not in local_part@domain format'
    end

    credentials = Ygg::Core::Person::Credential.where(fqda: fqda)
    raise FQDANotFound if !credentials.any?

    credential = credentials.to_a.find { |cr| cr.respond_to?(:match_by_password) && cr.match_by_password(password) }
    raise FQDANotFound if !credential

    return AuthenticationToken.new(
             person: credential.person,
             credential: credential,
             confidence: :medium,
             method: :fqda_and_password)
  end

  class KeyFobFormat < AuthenticationError ; end
  class KeyFobNotFound < AuthenticationError ; end

  def self.by_keyfob(keyfob_id:)
    if !keyfob_id.is_a?(String)
      raise KeyFobFormat, 'keyfob_id is in invalid format'
    end

    keyfob = Ygg::Acao::KeyFob.find_by(code: keyfob_id.upcase)
    raise KeyFobNotFound if !keyfob

    return AuthenticationToken.new(
             person: keyfob.person,
             credential: nil,
             confidence: :low,
             method: :keyfob)
  end

  class ProxyNotAuthorized < StandardError ; end
  class ProxyOtherFQDANotFound < StandardError ; end

  def self.proxy_by_fqda_and_password(fqda:, password:, other_fqda:)
    unless fqda =~ /^(.*)@(.*)$/
      raise FQDAFormat, 'FQDA is not in local_part@domain format'
    end

    unless other_fqda =~ /^(.*)@(.*)$/
      raise FQDAFormat, 'Other FQDA is not in local_part@domain format'
    end

    credentials = Ygg::Core::Person::Credential.where(fqda: fqda)
    raise FQDANotFound if !credentials.any?

    credential = credentials.to_a.find { |cr| cr.respond_to?(:match_by_password) && cr.match_by_password(password) }
    raise FQDANotFound if !credential

    raise ProxyNotAuthorized unless credential.person.has_global_roles?(:proxy_authenticate)

    other_cred = Ygg::Core::Person::Credential.find_by(fqda: other_fqda)
    raise ProxyOtherFQDANotFound if !other_cred

    return AuthenticationToken.new(
             person: other_cred.person,
             credential: credential,
             confidence: :medium,
             method: :proxy_fqda_and_password)
  end

  class CertNotFound < AuthenticationError ; end

  # Attempts authentication with specified X.509 certificate
  #
  # @param cert       OpenSSL X.590 certificate object
  # @return           Authentication token or nil if failed
  #
  # The matching process is the following:
  #
  # If the X.509 certificate is found in the identities' associeated certificates, the authentication is considered
  # successful and the authentication token is returned.
  #
  # If the certificate's emailAddress attribute matches an person's FQDA, that person is considered authenticated.
  # The certificate is also automatically associated to the person.
  #
  # If the certificate's CN attribute matches an person's FQDA, that person is considered authenticated
  # The certificate is also automatically associated to the person.
  #
  def self.by_cert(cert:)
    certcred = Ygg::Core::Person::Credential::X509Certificate.find_by(
      x509_i_dn: cert.issuer.to_s,
      x509_m_serial: cert.serial.to_s,
    )

    if !certcred
      cn_email = cert.subject.to_a.select { |v| v[0] == 'emailAddress' }.first[1].to_s
      cn = cert.subject.to_a.select { |v| v[0] == 'CN' }.first[1].to_s

      if cn_email || cn
        cred = Ygg::Core::Person::Credential.find_by(fqda: cn_email)
        cred ||= Ygg::Core::Person::Credential.find_by(fqda: cn)

        if cred
          certcred = Ygg::Core::Person::Credential::X509Certificate.create!(
            person: cred.person,
            fqda: cn_email,
            cert: cert,
          )
        end
      end
    end

    raise CertNotFound if !certcred

    return Ygg::Core::AuthenticationToken.new(
             credential: certcred,
             confidence: :strong,
             person: certcred.person,
             method: :client_cert_dn)
  end

end

end
end
