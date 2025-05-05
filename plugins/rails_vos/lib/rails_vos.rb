# frozen_string_literal: true
#
# Copyright (C) 2016-2023, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'rails_vos/version'
require 'rails_vos/server'

module RailsVos
  class Engine < Rails::Engine
    config.rails_vos = ActiveSupport::OrderedOptions.new if !defined? config.rails_vos
    config.rails_vos.allowed_request_origins = [ 'localhost' ]
    config.rails_vos.authentication_needed = true
    config.rails_vos.safe_receiver = false
    config.rails_vos.debug = 0
    config.rails_vos.routes = []
  end

  def self.start
    routes = Rails.application.config.rails_vos.routes
    routes.each do |ex_name, ex|
      ex[:queue] ||= Rails.application.config.rails_vos.shared_queue
    end

    begin
      Server.new(routes_config: routes.deep_dup)
    rescue Exception => e
      puts "EXCEPTION: #{e}"
    end
  end
end
