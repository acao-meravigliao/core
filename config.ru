# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

unless ENV['SKIP_AMQP_WS_GW']
  if defined? AmqpWsGw::Engine

    # Prevent autounloading
    require 'ygg/amqp_ws_gw/ws_connection'
    require 'ygg/amqp_ws_gw/gateway'
  end
end

run Rails.application
