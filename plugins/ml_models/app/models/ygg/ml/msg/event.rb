module Ygg
module Ml
class Msg < Ygg::PublicModel

class Event < Ygg::YggModel
  self.table_name = 'ml.msg_events'

  belongs_to :msg,
             class_name: '::Ygg::Ml::Msg'
end

end
end
end
