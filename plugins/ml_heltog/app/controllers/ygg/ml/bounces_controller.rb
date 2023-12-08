#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class BouncesController < HelTogether::Controller

  def bounce
    # No more than one rcpt is expected
    rcpt = payload[:rcpt].first

    Ygg::Ml::Bounce.report(rcpt: rcpt, from: payload[:from], body: payload[:body])

    return_from_action true
  end
end

end
end
