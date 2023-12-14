#
# Copyright (C) 2014-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ygg/amqp_ws_gw/gateway'

module Ygg
module AmqpWsGw
  def self.start
    routes = Rails.application.config.amqp_ws_gw.routes
    routes.each do |ex_name, ex|
      ex[:queue] ||= Rails.application.config.amqp_ws_gw.shared_queue
    end

    Gateway.new(routes_config: routes.deep_dup)
  end
end
end
