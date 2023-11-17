#
# Copyright (C) 2023-2023, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class SkysightCode < Ygg::PublicModel
  self.table_name = 'acao.skysight_codes'
  self.inheritance_column = false

  belongs_to :person,
             class_name: 'Ygg::Core::Person'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
