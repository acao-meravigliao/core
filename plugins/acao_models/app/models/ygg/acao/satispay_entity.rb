#
# Copyright (C) 2008-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class SatispayEntity < Ygg::PublicModel
  self.table_name = 'acao.satispay_entities'
  self.inheritance_column = false

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :profile_pictures,
           foreign_key: 'entity_id',
           class_name: '::Ygg::Acao::SatispayProfilePicture'

  has_many :payments,
           class_name: '::Ygg::Acao::Payment'

  gs_rel_map << { from: :entity, to: :profile_picture, to_cls: '::Ygg::Acao::SatispayProfilePicture', to_key: 'entity_id' }
  gs_rel_map << { from: :sp_sender, to: :payment, to_cls: '::Ygg::Acao::Payment', to_key: 'sp_sender_id' }
  gs_rel_map << { from: :sp_receiver, to: :payment, to_cls: '::Ygg::Acao::Payment', to_key: 'sp_receiver_id' }
end

end
end
