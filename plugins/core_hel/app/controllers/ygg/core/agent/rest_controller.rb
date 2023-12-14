#
# Copyright (C) 2012-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Agent::RestController < Ygg::Hel::RestController
  ar_controller_for Agent

  view :grid do
  end

  view :edit do
    self.with_perms = true
  end
end

end
end
