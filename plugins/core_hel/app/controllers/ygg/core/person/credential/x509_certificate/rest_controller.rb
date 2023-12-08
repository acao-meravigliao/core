#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person::Credential::X509Certificate::RestController < Ygg::Hel::RestController
  ar_controller_for Person::Credential::X509Certificate

  attribute(:sti_type) { ignore! }
  attribute(:data) { ignore! }
  attribute(:person_id) { ignore! }

  attribute :ascii_cert, type: :string do
  end

  attribute :x509_m_serial do
    not_writable!
    ignore!
  end

  attribute :x509_i_dn do
    not_writable!
    ignore!
  end

  attribute :x509_s_dn do
    not_writable!
    ignore!
  end

  attribute :x509_s_dn_cn do
    not_writable!
    ignore!
  end

  attribute :x509_s_dn_email do
    not_writable!
    ignore!
  end

  include RailsActiveRest::Controller::Responder
  def get_schema
    ar_respond_with(schema)
  end
end

end
end
