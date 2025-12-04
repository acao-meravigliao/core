# frozen_string_literal: true
#
# Copyright (C) 2017-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class RatingType < Ygg::PublicModel
  self.table_name = 'acao.rating_types'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  gs_rel_map << { from: :rating_type, to: :rating, to_cls: 'Ygg::Acao::License::Rating', to_key: 'rating_type_id', }
end

end
end
