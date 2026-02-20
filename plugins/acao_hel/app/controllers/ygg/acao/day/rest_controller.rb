#
# Copyright (C) 2016-2026, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Day::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::Day

  load_role_defs!

  member_action :daily_form

  def daily_form
    ar_retrieve_resource
    #ar_authorize_member_action

    render body: ar_resource.daily_form_pdf, content_type: 'application/pdf'
  end

end

end
end
