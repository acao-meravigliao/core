#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyStore::RestController < Ygg::Hel::RestController
  ar_controller_for KeyStore

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:symbol) { show! }
    attribute(:descr) { show! }
  end

  view :edit do
    self.with_perms = true
  end
end

end
end
