#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core
class Person

class Email < Ygg::PublicModel
  self.table_name = 'core.person_emails'

  belongs_to :person,
             class_name: '::Ygg::Core::Person'

  belongs_to :ml_address,
             class_name: '::Ygg::Ml::Address',
             optional: true

  define_default_log_controller(self)

  gs_rel_map << { from: :email, to: :person, to_cls: '::Ygg::Core::Person', from_key: 'person_id' }
  gs_rel_map << { from: :person_email, to: :ml_address, to_cls: '::Ygg::Ml::Address', from_key: 'ml_address_id' }

  after_create do
    ml_address_with_create
  end

  def ml_address_with_create
    ml_address || lookup_or_create_ml_address
  end

  def lookup_or_create_ml_address
    ml_addr = Ygg::Ml::Address.find_by(addr: email, addr_type: 'EMAIL')
    if ml_addr
      ml_addr.name = person.name
      ml_addr.save!
      self.ml_address = ml_addr
      save!
    else
      create_ml_address(addr: email, addr_type: 'EMAIL', name: person.name)
      save!
    end
  end

  def start_validation!
    mla = ml_address_with_create

    mla.start_validation!(person: person)
  end
end

end
end
end
