module Ygg
module Core
class Group < Ygg::PublicModel

class Member < Ygg::BasicModel
  self.table_name = 'core.group_members'

  belongs_to :person,
             :class_name => '::Ygg::Core::Person',
             optional: true

  belongs_to :group,
             :class_name => '::Ygg::Core::Group',
             optional: true

  define_default_log_controller(self)
end

end
end
end
