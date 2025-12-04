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
class License < Ygg::PublicModel

class Rating < Ygg::PublicModel
  self.table_name = 'acao.license_ratings'
  self.inheritance_column = false

  belongs_to :license,
             class_name: '::Ygg::Acao::License'

  belongs_to :rating_type,
             class_name: '::Ygg::Acao::RatingType'

  gs_rel_map << { from: :rating, to: :license, to_cls: 'Ygg::Acao::License', from_key: 'license_id', }
  gs_rel_map << { from: :rating, to: :rating_type, to_cls: 'Ygg::Acao::RatingType', from_key: 'rating_type_id', }
end

end
end
end
