#
# Copyright (C) 2024-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class ReplicaDef
  class_attribute :definitions
  self.definitions = {}

  def self.define(name:, **args)
    self.definitions[name] = self.new(name: name, **args)
  end

  def initialize(name:, query:)
    @name = name
  end

end

end
end
