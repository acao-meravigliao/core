#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class GlobalRole < Ygg::PublicModel

  self.table_name = 'core.global_roles'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'name', type: :string, limit: 32, null: false } ],
    [ :must_have_column, { name: 'descr', type: :string, limit: 255 } ],
  ]

  has_many :person_roles,
           class_name: '::Ygg::Core::Person::Role'

  has_many :people,
           class_name: '::Ygg::Core::Person',
           through: :person_roles

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def summary
    "#{name} - #{descr}"
  end
end

end
end
