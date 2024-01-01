#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

#require 'rails_vos/server/connection'

module RailsVos

module Rack
  def self.call(env)
puts "GGGGGGGGGGGGGGGGGGGGGGGGGGG 0"

    if !Rails.application.config.rails_vos.allowed_request_origins.any? { |allowed_origin| allowed_origin === env['HTTP_ORIGIN'] }
      Rails.logger.error("Request origin not allowed: #{env['HTTP_ORIGIN']}")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    req = ActionDispatch::Request.new(env)

    sess = Ygg::Core::HttpSession.find_by(id: req.cookies['X-Ygg-Session-Id'])
    if !sess && Rails.application.config.rails_vos.authentication_needed
      Rails.logger.error("Session '#{req.cookies['X-Ygg-Session-Id']}' not found")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    if Rails.application.config.rails_vos.authentication_needed && !sess.active?
      Rails.logger.error("Session '#{req.cookies['X-Ygg-Session-Id']}' not active")

      return [ 403, { 'Content-Type' => 'text/plain' }, [ 'Forbidden' ] ]
    end

    env['rack.hijack'].call
    socket = env['rack.hijack_io']

puts "GGGGGGGGGGGGGGGGGGGGGGGGGGG 1"
begin
    srv = AM::Registry[:rails_vos_server]

    srv.tell(RailsVos::Server::MsgNewConnection.new(
      env: env,
      session: sess,
      headers: req.headers,
      socket: socket,
      routes_config: Rails.application.config.rails_vos.routes,
      debug: Rails.application.config.rails_vos.debug,
    ))

rescue Exception => e
  puts "EXCEPTION: #{e}"
end
puts "GGGGGGGGGGGGGGGGGGGGGGGGGGG 2"

    [ -1, {}, [] ]
  end
end

end
