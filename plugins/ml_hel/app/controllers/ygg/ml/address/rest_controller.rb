#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Address::RestController < Ygg::Hel::RestController
  ar_controller_for Address

  def validate
    tok = Ygg::Ml::Address::ValidationToken.find_by(code: params[:code])
    if !tok
      respond_to do |format|
        format.json { render :json => { success: false, error: 'TokenNotFound' } }
      end

      return
    end

    if (tok.expires_at && Time.now > tok.expires_at)
      respond_to do |format|
        format.json { render :json => { success: false, error: 'TokenExpired' } }
      end

      return
    end

    if (tok.used_at)
      respond_to do |format|
        format.json { render :json => { success: false, error: 'TokenAlreadyUsed' } }
      end

      return
    end

    tok.update!(
      http_remote_addr: request.env['REMOTE_ADDR'],
      http_remote_port: request.env['REMOTE_PORT'],
      http_x_forwarded_for: request.env['HTTP_X_FORWARDED_FOR'],
      http_via: request.env['HTTP_VIA'],
      http_server_addr: request.env['SERVER_ADDR'],
      http_server_port: request.env['SERVER_PORT'],
      http_server_name: request.env['HTTP_HOST'],
      http_referer: request.env['HTTP_REFERER'],
      http_user_agent: request.env['HTTP_USER_AGENT'],
      http_request_uri: request.env['REQUEST_URI'],
    )

    tok.validated!

    respond_to do |format|
      format.json { render :json => {
        success: true,
        address: tok.address.addr,
      } }
    end
  end
end

end
end
