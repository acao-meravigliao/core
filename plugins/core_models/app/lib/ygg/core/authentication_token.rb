#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

  class AuthenticationToken
    attr_accessor :person
    attr_accessor :credential
    attr_accessor :confidence
    attr_accessor :method

    def initialize(h = {})
      h.each { |k,v| send("#{k}=", v) }
    end
  end

end
end
