#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class License < Ygg::PublicModel
  self.table_name = 'acao.licenses'
  self.inheritance_column = false

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  has_many :ratings,
           class_name: '::Ygg::Acao::License::Rating',
           embedded: true,
           autosave: true,
           dependent: :destroy

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_meta_class

  idxc_cached
  self.idxc_sensitive_attributes = [
    :member_id,
  ]
end

end
end
