#
# Copyright (C) 2012-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class LeAccount::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Ca::LeAccount

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:symbol) { show! }
    attribute(:endpoint) { show! }
    attribute(:descr) { show! }
  end

  view :edit do
    self.with_perms = true

    attribute(:key_pair) do
      show!
    end
  end
end

end
end
