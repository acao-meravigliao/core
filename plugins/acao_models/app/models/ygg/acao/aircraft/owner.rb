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

class Aircraft < Ygg::PublicModel
class Owner < Ygg::PublicModel
  self.table_name = 'acao.aircraft_owners'

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  gs_rel_map << { from: :aircraft_owner, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :aircraft_owner, to: :aircraft, to_cls: 'Ygg::Acao::Aircraft', from_key: 'aircraft_id', }
end
end

end
end
