#
# Copyright (C) 2013-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Template::RestController < Ygg::Hel::RestController

  ar_controller_for Template

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:symbol) { show! }
    attribute(:subject) { show! }
    attribute(:language) do
      attribute(:name) { show! }
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:language) { show! }
  end
end

end
end
