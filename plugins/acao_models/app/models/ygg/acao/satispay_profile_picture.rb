#
# Copyright (C) 2008-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class SatispayProfilePicture < Ygg::PublicModel
  self.table_name = 'acao.satispay_profile_pictures'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :entity,
             class_name: '::Ygg::Acao::SatispayEntity'

  gs_rel_map << { from: :profile_picture, to: :entity, to_cls: '::Ygg::Acao::SatispayEntity', from_key: 'entity_id' }
end

end
end
