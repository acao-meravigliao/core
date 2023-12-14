#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

class BasicController
  include ActiveRest::Controller
  include Ygg::Core::RoleDefsLoader

  collection_action :index
  collection_action :create

  collection_role(:superuser,
    allow_all_actions: true,
    all_readable: true,
    all_writable: true,
  )

  member_action :index
  member_action :show
  member_action :update
  member_action :destroy

  member_role(:superuser,
    allow_all_actions: true,
    all_readable: true,
    all_writable: true,
  )
end

end
end
