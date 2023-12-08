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

class Contact < Ygg::PublicModel
  self.table_name = 'core.person_contacts'
  self.inheritance_column = false

  belongs_to :person,
             class_name: '::Ygg::Core::Person',
             embedded_in: true

  define_default_log_controller(self)
end

end
end
end
