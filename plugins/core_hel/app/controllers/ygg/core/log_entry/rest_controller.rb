#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class LogEntry::RestController < Ygg::Hel::RestController

  ar_controller_for LogEntry

  view :_default_ do
    empty!
    attribute(:id) { show! }
    attribute(:timestamp) { show! }
    attribute(:description) { show! }
    attribute(:person) { show! }
  end

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:timestamp) { show! }
    attribute(:description) { show! }
    attribute(:http_session) { show! }
  end

  view :edit do
    self.with_perms = true

    attribute(:person) { show! }
    attribute(:http_session) { show! }

    attribute(:details) do
      attribute(:previous) do
        show!
      end
    end
  end

  view :objlog do
    empty!
    attribute(:id) { show! }
    attribute(:timestamp) { show! }
    attribute(:person) do
      show!
      empty!
      attribute(:first_name) { show! }
      attribute(:last_name) { show! }
    end
    attribute(:description) { show! }
  end

end

end
end
