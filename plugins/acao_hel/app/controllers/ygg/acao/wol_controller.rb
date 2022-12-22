#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class WolController < Ygg::Hel::BaseController
  layout false

  def wake
#    ensure_authenticated!
#
#    raise "Föra di ball" unless aaa_context.has_global_roles?(:superuser)

    target = Ygg::Acao::WolTarget.find_by!(symbol: json_request[:symbol])

    target.wake!

    respond_to do |format|
      format.json { render json: {} }
    end
  end
end

end
end
