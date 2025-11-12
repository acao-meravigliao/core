#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

#require 'rails_vos/server/connection'

require 'am/http/server'

module RailsVos

module Rack
  def self.call(env)
    if !Rails.application.config.rails_vos.allowed_request_origins.any? { |allowed_origin| allowed_origin === env['HTTP_ORIGIN'] }
      Rails.logger.error("Request origin not allowed: #{env['HTTP_ORIGIN']}")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    req = ActionDispatch::Request.new(env)

    sess = Ygg::Core::Session.find_by(id: req.cookies['Session-Id'])
    if !sess && Rails.application.config.rails_vos.authentication_needed
      Rails.logger.error("Session '#{req.cookies['Session-Id']}' not found")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    if Rails.application.config.rails_vos.authentication_needed && !sess.active?
      Rails.logger.error("Session '#{req.cookies['Session-Id']}' not active")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    srv = AM::Registry[:rails_vos_server]

    env['rack.hijack'].call
    socket = env['rack.hijack_io']

    # Emulate a HTTP request to VOS server
    res = srv.ask(AM::HTTP::Server::MsgRequest.new(
      id: SecureRandom.uuid,
      scheme: req.scheme,
      verb: req.method,
      uri: req.url,
      version: req.version,
      headers: req.headers,
#      body:,
      socket: socket,
#      tls:,
#      tls_server_cert:,
#      tls_client_cert:,
#      tls_client_cert_chain:,
#      tls_cipher:,
#      tls_version:,
#      tls_verify_result:,
#
#      local_endpoint:,
#      remote_endpoint:,
#      remote_endpoint_real:,
#
#      bound_to:,
#
#      routes_config: Rails.application.config.rails_vos.routes,
#      debug: Rails.application.config.rails_vos.debug,
    )).value

    if res.is_a?(AM::HTTP::Server::MsgRequestHijack)
    end

    [ -1, {}, [] ]

  rescue Exception => e
    puts "EXCEPTION: #{e}"
    puts "EXCEPTION: #{e.backtrace}"

  end
end

end
