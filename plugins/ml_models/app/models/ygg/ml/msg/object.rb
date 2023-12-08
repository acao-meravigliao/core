module Ygg
module Ml
class Msg < Ygg::PublicModel

class Object < Ygg::BasicModel
  self.table_name = 'ml.msg_objects'

  belongs_to :msg,
             class_name: '::Ygg::Ml::Msg'

  belongs_to :object,
             class_name: '::Ygg::Ml::Object',
             polymorphic: true

  define_default_log_controller(self)
end

end
end
end
