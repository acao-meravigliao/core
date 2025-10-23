# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Medical < Ygg::PublicModel
  self.table_name = 'acao.medicals'
  self.inheritance_column = false

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  gs_rel_map << { from: :medical, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_meta_class

  idxc_cached
  self.idxc_sensitive_attributes = [
    :pilot_id,
  ]

end

end
end
