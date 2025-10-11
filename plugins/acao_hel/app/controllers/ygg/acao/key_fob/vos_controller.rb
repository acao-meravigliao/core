#
# Copyright (C) 2016-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Acao

class KeyFob::VosController < Ygg::Hel::VosBaseController

  def faac_status(code:, **)
    faac = FaacApi::Client.new(
      endpoint: Rails.application.config.acao.faac_endpoint,
      debug: 0,
    )

    faac.login(
      username: Rails.application.config.acao.faac_generic_user,
      password: Rails.application.credentials.faac_generic_user_password
    )

    res = faac.media_get_by_code(code)

    if res
     return {
       user_name: res[:userLastAndFirstName],
       enabled: res[:enabled],
       validity_start: res[:validityStart],
       validity_end: res[:validityEnd],
      }
    else
      return {
        error: 'Not found'
      }
    end
  end

  def status(obj:, **)
    ensure_authenticated!

    {
     validity_start: obj.validity_start,
     validity_end: obj.validity_end,
     validity_ranges: obj.validity_ranges.map { |x| [ x.begin, x.end ] },
    }
  end

end

end
end
