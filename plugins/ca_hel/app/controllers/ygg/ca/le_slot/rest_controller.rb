#
# Copyright (C) 2012-2020, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class LeSlot::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Ca::LeSlot

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:renew_at) { show! }
    attribute(:account) do
      show!
      empty!
      attribute(:symbol) { show! }
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:account) do
      show!
    end

    attribute(:certificate) do
      show!
    end
  end
end

end
end
