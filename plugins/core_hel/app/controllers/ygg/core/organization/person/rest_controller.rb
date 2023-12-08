#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Organization::Person::RestController < Ygg::Hel::RestController
  ar_controller_for Organization::Person
end

end
end
