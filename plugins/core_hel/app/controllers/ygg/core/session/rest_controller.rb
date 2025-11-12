#
# Copyright (C) 2013-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Session::RestController < Ygg::Hel::RestController

  ar_controller_for Session

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:created_at) { show! }
    attribute(:person) do
      show!
      empty!
      attribute(:id) { show! }
      attribute(:first_name) { show! }
      attribute(:last_name) { show! }
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:person) do
      show!
    end
  end

end

end
end
