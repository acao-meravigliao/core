#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Gate::RestController < Ygg::Hel::RestController

  ar_controller_for Ygg::Acao::Gate

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:name) { show! }
    attribute(:descr) { show! }
  end

  view :edit do
    self.with_perms = true

    attribute(:agent) do
      show!
    end
  end

end

end
end
