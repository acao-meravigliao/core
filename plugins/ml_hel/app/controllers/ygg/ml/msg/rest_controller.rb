#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Msg::RestController < Ygg::Hel::RestController
  ar_controller_for Msg

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:created_at) { show! }
    attribute(:abstract) { show! }
    attribute(:status) { show! }
    attribute(:email_message_id) { show! }

    attribute(:recipient) do
      empty!
      attribute(:addr) { show! }
    end
  end

  view :edit do
    attribute(:sender) do
      show!
    end

    attribute(:recipient) do
      show!
    end

    attribute(:msg_lists) do
      show!
      attribute(:list) do
        show!
      end
    end
  end
end

end
end
