# frozen_string_literal: true
#
# Copyright (C) 2016-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Member < Ygg::PublicModel
class Role < Ygg::PublicModel
  self.table_name = 'acao.member_roles'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  gs_rel_map << { from: :role, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
end
end

end
end
