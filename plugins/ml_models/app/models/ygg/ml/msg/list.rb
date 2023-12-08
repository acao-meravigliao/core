module Ygg
module Ml
class Msg < Ygg::PublicModel

class List < Ygg::YggModel
  self.table_name = 'ml.msg_lists'

  belongs_to :msg,
             class_name: '::Ygg::Ml::Msg'

  belongs_to :list,
             class_name: '::Ygg::Ml::List'

  define_default_log_controller(self)
end

end
end
end
