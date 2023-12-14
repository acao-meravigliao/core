#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core
class Person
class Credential

class X509Certificate < Credential

  def confidence
    return :strong
  end

  def ascii_cert=(cert)
    self.cert = cert
  end

  def ascii_cert
    self.cert.to_s
  end

  def cert=(cert)
    @cert = cert

    if cert.is_a?(String)
      @cert = OpenSSL::X509::Certificate.new(cert)
    end

    self.x509_m_serial = @cert.serial.to_s
    self.x509_i_dn = @cert.issuer.to_s
    self.x509_s_dn = @cert.subject.to_s
    self.x509_s_dn_cn = @cert.subject.to_a.detect { |v| v[0] == 'CN' }.try { |x| x[1] }
    self.x509_s_dn_email = @cert.subject.to_a.detect { |v| v[0] == 'emailAddress' }.try { |x| x[1] }

    self.data = @cert.to_s
  end

  def cert
    @cert || @cert = OpenSSL::X509::Certificate.new(self.data)
  end

  def cert_match(cert)
    if cert.is_a?(String)
      cert = OpenSSL::X509::Certificate.new(cert)
    end

    return self.x509_m_serial == cert.serial && self.x509_i_dn == cert.issuer
  end

  def label
    cn
  end

  def summary
    cn
  end
end

end
end
end
end
