#
# Copyright (C) 2012-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class Certificate::RestController < Ygg::Hel::RestController
  ar_controller_for Certificate

  attribute(:key_pair_id) { not_writable! ; ignore! }
  attribute(:key_pair) { not_writable! ; ignore! }
  attribute(:valid_from) { not_writable! ; ignore! }
  attribute(:valid_to) { not_writable! ; ignore! }
  attribute(:serial) { not_writable! ; ignore! }
  attribute(:issuer_cn) { not_writable! ; ignore! }
  attribute(:subject_dn) { not_writable! ; ignore! }
  attribute(:issuer_dn) { not_writable! ; ignore! }
  attribute(:cn) { not_writable! ; ignore! }
  attribute(:email) { not_writable! ; ignore! }

  view :grid do
  end

  view :edit do
    attribute(:key_pair) do
      show!
    end
  end
end

end
end
