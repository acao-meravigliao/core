# frozen_string_literal: true
#
# Copyright (C) 2026-2026, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
class Member < Ygg::PublicModel

class PmNote < Ygg::PublicModel
  self.table_name = 'acao.member_pm_notes'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  gs_rel_map << { from: :pm_note, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :pm_note, to: :author, to_cls: 'Ygg::Acao::Member', from_key: 'author_id', }
end

end
end
end
