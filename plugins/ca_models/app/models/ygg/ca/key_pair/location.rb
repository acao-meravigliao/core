module Ygg
module Ca
class KeyPair < Ygg::PublicModel

class Location < Ygg::BasicModel
  belongs_to :pair,
             class_name: '::Ygg::Ca::KeyPair'

  belongs_to :store,
             class_name: '::Ygg::Ca::KeyStore'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
end
