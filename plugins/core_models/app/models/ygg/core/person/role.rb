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

class Role < Ygg::BasicModel

  self.table_name = 'core.person_roles'

  belongs_to :person,
             class_name: 'Ygg::Core::Person',
             foreign_key: 'person_id',
             embedded_in: true

  belongs_to :global_role,
             class_name: 'Ygg::Core::GlobalRole',
             foreign_key: 'global_role_id'

  define_default_log_controller(self)
end

end
end
end
