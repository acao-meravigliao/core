#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Club::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::Club

  load_role_defs!
end

end
end
