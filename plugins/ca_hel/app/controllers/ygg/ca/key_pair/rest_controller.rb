#
# Copyright (C) 2012-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyPair::RestController < Ygg::Hel::RestController
  ar_controller_for KeyPair

  attribute(:key_type) { not_writable! }
  attribute(:key_length) { not_writable! }

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:key_type) { show! }
    attribute(:key_length) { show! }
    attribute(:created_at) { show! }
    attribute(:public_key_hash) { show! }
    attribute(:descr) { show! }

    attribute(:locations) do
      show!
      empty!
      attribute(:path)
      attribute(:store) do
        show!
        empty!
        attribute(:symbol)
      end
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:locations) do
      show!
    end
  end
end

end
end
