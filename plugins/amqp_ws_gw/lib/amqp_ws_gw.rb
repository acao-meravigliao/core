#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'amqp_ws_gw/version'

module AmqpWsGw

class Engine < Rails::Engine
  config.amqp_ws_gw = ActiveSupport::OrderedOptions.new if !defined? config.amqp_ws_gw
  config.amqp_ws_gw.allowed_request_origins = [ 'localhost' ]
  config.amqp_ws_gw.authentication_needed = true
  config.amqp_ws_gw.safe_receiver = false
  config.amqp_ws_gw.debug = 0
end

end
