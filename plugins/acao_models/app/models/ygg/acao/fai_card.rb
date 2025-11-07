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

class FaiCard < Ygg::PublicModel
  self.table_name = 'acao.fai_cards'
  self.inheritance_column = false

  belongs_to :member,
             class_name: '::Ygg::Acao::Member'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_meta_class

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

end

end
end
