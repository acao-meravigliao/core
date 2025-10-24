#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Core

class Person::Email::VosController < Ygg::Hel::VosBaseController
  def request_validation(obj:, **)
    obj.start_validation!
  end
end

end
end
