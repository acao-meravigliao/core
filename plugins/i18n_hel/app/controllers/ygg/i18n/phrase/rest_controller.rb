#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module I18n

class Phrase::RestController < Ygg::Hel::RestController
  ar_controller_for Phrase

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:phrase) { show! }
  end

  view :edit do
    attribute(:translations) do
      show!
      attribute(:language) do
        empty!
        self.with_type = false
        attribute(:id) { show! }
        attribute(:iso_639_1) { show! }
        attribute(:descr) { show! }
      end
    end
  end
end

end
end
