#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Replica::RestController < Ygg::Hel::RestController

  ar_controller_for Replica

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:obj_type) { show! }
    attribute(:obj_id) { show! }
    attribute(:identifier) { show! }
    attribute(:state) { show! }
    attribute(:descr) { show! }
    attribute(:version_needed) { show! }
    attribute(:version_pending) { show! }
    attribute(:version_done) { show! }
  end

  view :edit do
    self.with_perms = true
  end
end

end
end
