#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Group::RestController < Ygg::Hel::RestController
  ar_controller_for Group

  view :edit do
    self.with_perms = true

#    attribute :acl_entries do
##      show!
#      attribute :group do
##        show!
#        empty!
#        attribute(:name) { show! }
#      end
#      attribute :person do
##        show!
#        empty!
#        attribute(:first_name) { show! }
#        attribute(:last_name) { show! }
#        attribute(:handle) { show! }
#        attribute(:italian_fiscal_code) { show! }
#      end
#    end

    attribute(:group_members) do
      attribute(:person) do
#        show!
        empty!
        attribute(:id) { show! }
        attribute(:first_name) { show! }
        attribute(:last_name) { show! }
      end
    end
  end
end

end
end
