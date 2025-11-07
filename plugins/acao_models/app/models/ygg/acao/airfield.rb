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
  self.table_name = 'acao.airfields'

  belongs_to :location,
             class_name: '::Ygg::Core::Location',
             embedded: true,
             autosave: true

  has_many :circuits,
           class_name: '::Ygg::Acao::Airfield::Circuit',
           embedded: true,
           autosave: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
