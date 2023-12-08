#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Sender::RestController < Ygg::Hel::RestController
  ar_controller_for Sender

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:name) { show! }
    attribute(:email_address) { show! }
    attribute(:symbol) { show! }
    attribute(:descr) { show! }
  end

  view :edit do
    attribute(:email_dkim_key_pair) do
      show!
    end
  end
end

end
end
