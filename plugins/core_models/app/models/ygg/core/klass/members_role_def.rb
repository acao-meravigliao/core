module Ygg
module Core
class Klass < Ygg::PublicModel

class MembersRoleDef < Ygg::BasicModel
  self.table_name = 'core.klass_members_role_defs'

  belongs_to :klass,
             class_name: '::Ygg::Core::Klass'

  serialize :attrs, JSON
  serialize :actions, JSON

  define_default_log_controller(self)
end

end
end
end
