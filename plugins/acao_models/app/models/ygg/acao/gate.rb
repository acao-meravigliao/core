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

class Gate < Ygg::PublicModel
  self.table_name = 'acao.gates'

  belongs_to :agent,
             class_name: '::Ygg::Core::Agent',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
