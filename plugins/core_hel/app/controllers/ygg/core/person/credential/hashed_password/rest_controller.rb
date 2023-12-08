#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person::Credential::HashedPassword::RestController < Ygg::Hel::RestController
  ar_controller_for Person::Credential::HashedPassword

  attribute(:password, type: :string) do
    not_readable!
  end

  attribute(:sti_type) { ignore! }
  attribute(:data) { ignore! }
  attribute(:person_id) { ignore! }
  attribute(:ascii_cert) { ignore! ; not_readable! }
  attribute(:x509_m_serial) { ignore! }
  attribute(:x509_i_dn) { ignore! }
  attribute(:x509_s_dn) { ignore! }
  attribute(:x509_s_dn_cn) { ignore! }
  attribute(:x509_s_dn_email) { ignore! }

  #ExtJS sucks
  #remove_attribute(:sti_type)
  #remove_attribute(:data)
  #remove_attribute(:person_id)
  #remove_attribute(:ascii_cert)
  #remove_attribute(:x509_m_serial)
  #remove_attribute(:x509_i_dn)
  #remove_attribute(:x509_s_dn)
  #remove_attribute(:x509_s_dn_cn)
  #remove_attribute(:x509_s_dn_email)

  include RailsActiveRest::Controller::Responder
  def get_schema
    ar_respond_with(schema)
  end
end

end
end
