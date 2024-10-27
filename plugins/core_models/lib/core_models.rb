# frozen_string_literal: true
#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'core_models/version'

require 'ygg/hel/require_recursive'

Ygg::Hel.require_recursive('*.rb', File.join(File.dirname(__FILE__), 'ygg', 'hel', 'overrides') , true)

module Ygg
module Core

class ModelsEngine < Rails::Engine
  config.core = ActiveSupport::OrderedOptions.new if !defined? config.core
  config.core.replicas_notify_enabled = true
  config.core.replicas_enabled = true
  config.core.lc_enabled = true
  config.core.lc_exchange = 'ygg.model.events'
  config.core.task_notify_enabled = true
  config.core.session_data_handlers = []
  config.core.session_after_authenticated_hooks = []
  config.exchanges_prefix = 'ygg'
end

end
end
