#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module ActionDispatch #:nodoc:
module Routing #:nodoc:
class Mapper #:nodoc:

module Resources
  def hel_resources(*resources, &block)
    aresources(*resources) do
      member do
        get :log_entries
        get :notifications
      end

      yield if block_given?
    end
  end
end

end
end
end
