#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Member::VosController < Ygg::Hel::VosBaseController
  def roster_status(year:, **)
    ensure_authenticated!
    member = session.auth_person.acao_member

    res = member.roster_status(time: Time.new(year, 1, 1))

    res
  end
end

end
end
