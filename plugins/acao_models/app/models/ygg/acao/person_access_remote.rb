#
# Copyright (C) 2024-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao

class PersonAccessRemote < Ygg::PublicModel
  self.table_name = 'acao.person_access_remotes'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :member,
             class_name: 'Ygg::Core::Member'

  belongs_to :remote,
             class_name: 'Ygg::Acao::AccessRemote'
end

end
end
