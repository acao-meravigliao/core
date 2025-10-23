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
  gs_rel_map << { from: :email, to: :validation_token, to_cls: '::Ygg::Core::Person::Email::ValidationToken', to_key: 'person_email_id' }
end

end
end
end
