#
# Copyright (C) 2016-2026, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Acao

class Day::VosController < Ygg::Hel::VosBaseController

#  def daily_form
#    ar_retrieve_resource
#    ar_authorize_member_action
#
#    respond_to do |format|
#      format.pdf do
#        render body: ar_resource.daily_form_pdf, content_type: 'application/pdf'
#      end
#    end
#  end

  def print(obj:, body:, **)
    ensure_authenticated!

    obj.print_daily_form
  end

end

end
end
