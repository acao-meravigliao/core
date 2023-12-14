#
# Copyright (C) 2013-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module HasMetaClass
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def has_meta_class
      self.porn_migration << [ :must_have_record, { klass: 'Ygg::Core::Klass', attrs: { name: name } } ]
    end

    def meta_class
      return if name == 'Ygg::Core::Klass'
      Ygg::Core::Klass.find_by(name: name)
    end
  end
end

end
end
