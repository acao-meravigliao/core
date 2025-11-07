#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyStore < Ygg::PublicModel
  self.table_name = 'ca.key_stores'
#  self.abstract_class = true
  self.inheritance_column = :sti_type

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :model_pair_locations,
           class_name: '::Ygg::Ca::KeyPair::Location',
           foreign_key: :store_id

  has_many :model_pairs,
           class_name: '::Ygg::Ca::KeyPair',
           through: :model_pair_locations,
           source: :pair
end

end
end
