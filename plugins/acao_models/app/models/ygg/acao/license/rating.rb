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

class Rating < Ygg::BasicModel
  self.table_name = 'acao.license_ratings'
  self.inheritance_column = false

  belongs_to :license,
             class_name: '::Ygg::Acao::License'
end

end
end
end
