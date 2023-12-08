#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Bounce::RestController < Ygg::Hel::RestController
  ar_controller_for Bounce

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:type) { show! }
    attribute(:received_at) { show! }
    attribute(:status) { show! }
    attribute(:action) { show! }
    attribute(:disposition) { show! }
    attribute(:disposition_error) { show! }
  end

  view :edit do
  end
end

end
end
