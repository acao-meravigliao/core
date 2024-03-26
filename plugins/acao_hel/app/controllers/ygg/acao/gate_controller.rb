#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class GateController < Ygg::Hel::BaseController
  layout false

  def open
    ensure_authenticated!

    raise "Föra di ball" unless aaa_context.has_global_roles?(:superuser)

    action_uuid = Rails.application.config.acao.faac_actions[json_request[:symbol].to_sym]

    raise "Action not found" if !action_uuid

    faac = FaacApi::Client.new(
      endpoint: Rails.application.config.acao.faac_endpoint,
      debug: Rails.application.config.acao.faac_debug,
    )

    # FIXME: use personal credentials
    faac.login(
      username: Rails.application.config.acao.faac_generic_user,
      password: Rails.application.secrets.faac_generic_user_password,
    )

    faac.action_perform(uuid: action_uuid)

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  def event
    puts json_request

    respond_to do |format|
      format.json { render json: { success: true } }
    end
  end
end

end
end
