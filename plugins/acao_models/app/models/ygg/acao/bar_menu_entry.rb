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

class BarMenuEntry < Ygg::PublicModel
  self.table_name = 'acao.bar_menu_entries'
  self.inheritance_column = false

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_meta_class
end

end
end
