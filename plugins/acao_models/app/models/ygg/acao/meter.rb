# frozen_string_literal: true
#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Meter < Ygg::PublicModel
  self.table_name = 'acao.meters'

  belongs_to :member,
             class_name: 'Ygg::Core::Member',
             optional: true

  belongs_to :bus,
             class_name: '::Ygg::Acao::MeterBus'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
