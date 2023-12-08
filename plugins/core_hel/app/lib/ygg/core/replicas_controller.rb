#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module ReplicasController
  extend ActiveSupport::Concern

  included do
    collection_action :replicas_force

    attribute(:replicas_state) { not_writable! ; ignore! }
  end
end

end
end
