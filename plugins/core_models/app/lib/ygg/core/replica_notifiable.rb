#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'hooks'

module Ygg
module Core

module ReplicaNotifiable
  extend ActiveSupport::Concern

  included do
    include Hooks unless included_modules.include?(Hooks)
    define_hooks :replicas_completed, :replica_failed
  end
end

end
end
