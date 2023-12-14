#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Labeled

  # Provide a human-recognizable name for the service
  # In this base class it attempts to call #name or #hostname
  #
  # it is supposed to be overridden by child classes in order to provide a meaningful name
  #
  def label
    return name if respond_to? :name
    return hostname if respond_to? :hostname
    to_s
  end
end

end
end
