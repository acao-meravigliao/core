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
class Airfield < Ygg::PublicModel

class Circuit < Ygg::BasicModel
  self.table_name = 'acao.airfield_circuits'

  belongs_to :airfield,
             class_name: '::Ygg::Acao::Airfield'
end

end
end
end
