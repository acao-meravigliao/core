#
# Copyright (C) 2013-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class IndexCacheEntry < ActiveRecord::Base
  self.table_name = 'idxc_entries'

  belongs_to :obj,
             polymorphic: true

  belongs_to :person,
             class_name: '::Ygg::Core::Person'
end

end
end
