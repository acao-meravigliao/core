#
# Copyright (C) 2012-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Agent < Ygg::PublicModel
  self.table_name = 'core.agents'

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  ## No attribute is sensitive for authorization
  #idxc_cached
  #self.idxc_sensitive_attributes = []

  validates :exchange, presence: true

  def rpc(operation:, data: nil, timeout: 5.seconds)
    RailsAmqp.interface.task(
      exchange: exchange,
      operation: operation,
      data: data,
      timeout: timeout,
    )
  end

  def send_exit
    rpc(operation: :exit)
  end
end

end
end

