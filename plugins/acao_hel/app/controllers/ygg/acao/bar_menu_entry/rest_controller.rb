#
# Copyright (C) 2016-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class BarMenuEntry::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::BarMenuEntry

  load_role_defs!

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:descr) { show! }
    attribute(:price) { show! }
    attribute(:on_sale) { show! }
  end

  view :edit do
    self.with_perms = true
  end
end

end
end
