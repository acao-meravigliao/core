#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

#require 'plugins/amqp_ws_gw/lib/ygg/amqp_ws_gw/ws_connection'
require 'ygg/amqp_ws_gw/ws_connection'

module Ygg
module AmqpWsGw

module Rack
  def self.call(env)
    if !Rails.application.config.amqp_ws_gw.allowed_request_origins.any? { |allowed_origin| allowed_origin === env['HTTP_ORIGIN'] }
      Rails.logger.error("Request origin not allowed: #{env['HTTP_ORIGIN']}")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    req = ActionDispatch::Request.new(env)

    sess = Ygg::Core::HttpSession.find_by(id: req.cookies['X-Ygg-Session-Id'])
    if !sess && Rails.application.config.amqp_ws_gw.authentication_needed
      Rails.logger.error("Session '#{req.cookies['X-Ygg-Session-Id']}' not found")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    if Rails.application.config.amqp_ws_gw.authentication_needed && !sess.active?
      Rails.logger.error("Session '#{req.cookies['X-Ygg-Session-Id']}' not active")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    env['rack.hijack'].call
    socket = env['rack.hijack_io']

    server = WsConnection.new(env: env, session: sess, headers: req.headers, socket: socket,
      routes_config: Rails.application.config.amqp_ws_gw.routes,
      debug: Rails.application.config.amqp_ws_gw.debug,
    )

    [ -1, {}, [] ]
  end
end

end
end
