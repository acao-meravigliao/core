#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class SuperuserContext < ActiveRest::AAAContext
  def initialize(auth_person:, global_roles: [])
    super(auth_person: auth_person, global_roles: global_roles + [ :superuser ])
  end
end

end
end
