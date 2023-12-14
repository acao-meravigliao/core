#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg

#
# Standalone object with authorization, accounting, uuid.
#
# Should not be embedded (?)
#
# The derived models will also have all the operations logged
#
class YggModel < BasicModel
  self.abstract_class = true
end

end
