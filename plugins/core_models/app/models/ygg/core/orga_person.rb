#
# Copyright (C) 2012-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class OrgaPerson < Ygg::PublicModel
  self.abstract_class = true
#  self.sti_type = :sti_type

  if defined? ShopModels
    include Ygg::Shop::Billable
  end
end

end
end
