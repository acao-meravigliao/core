module Ygg
module Core
class Organization < OrgaPerson

class Person < Ygg::BasicModel
  self.table_name = 'core.organization_people'

  belongs_to :organization,
             :class_name => '::Ygg::Core::Organization'

  belongs_to :person,
             :class_name => '::Ygg::Core::Person'

  define_default_log_controller(self)
end

end
end
end
