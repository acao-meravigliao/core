#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Location::RestController < Ygg::Hel::RestController
  ar_controller_for Location

  load_role_defs!
end

end
end
