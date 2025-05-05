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

class Trailer < Ygg::PublicModel
  self.table_name = 'acao.trailers'

  belongs_to :member,
             class_name: 'Ygg::Core::Member',
             optional: true

  belongs_to :aircraft,
             class_name: '::Ygg::Acao::Aircraft',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id
  ]

end

end
end
