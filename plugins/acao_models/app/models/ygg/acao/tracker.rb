# frozen_string_literal: true
#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Tracker < Ygg::PublicModel
  self.table_name = 'acao.trackers'
  self.inheritance_column = false

  belongs_to :aircraft,
             class_name: 'Ygg::Acao::Aircraft',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
