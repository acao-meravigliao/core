#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'uuidtools'

class UUIDTools::UUID
#  def ar_serializable_hash(ifname, opts = {})
#    to_s
#  end

  def as_json(opts = nil)
    to_s
  end
end
