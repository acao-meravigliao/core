
module Ygg
module Core

class ReplicaMessagesController < HelTogether::Controller
  def process_all
    Ygg::Core::Replica.process_all!

    return_from_action true
  end
end

end
end
