#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Streaming

class Channel::Variant::RestController < Ygg::Hel::RestController
  ar_controller_for Channel::Variant

  member_role(:anonymous,
    allow_all_actions: true,
    all_readable: true,
  )
end

end
end
