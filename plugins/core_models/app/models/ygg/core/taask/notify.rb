module Ygg
module Core
class Taask < Ygg::PublicModel

class Notify < Ygg::BasicModel
  belongs_to :task,
             class_name: '::Ygg::Core::Taask'

  belongs_to :obj,
             polymorphic: true
end

end
end
end
