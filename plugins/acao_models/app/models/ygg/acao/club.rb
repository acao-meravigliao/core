# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao

class Club < Ygg::PublicModel
  self.table_name = 'acao.clubs'

  has_many :aircrafts,
           class_name: '::Ygg::Acao::Aircraft'

  belongs_to :airfield,
             class_name: '::Ygg::Acao::Airfield',
             optional: true

  has_many :aircrafts_as_owner,
           class_name: '::Ygg::Acao::Aircraft'

  gs_rel_map << { from: :club_owner, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', to_key: 'club_owner_id', }
  gs_rel_map << { from: :club, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', to_key: 'club_id', }
  gs_rel_map << { from: :club, to: :airfield, to_cls: 'Ygg::Acao::Airfield', from_key: 'airfield_id', }

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
