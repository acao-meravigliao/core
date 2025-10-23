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

class Role < Ygg::PublicModel
  self.table_name = 'acao.roles'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
