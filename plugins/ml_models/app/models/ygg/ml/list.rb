#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class List < Ygg::PublicModel
  self.table_name = 'ml.lists'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: true}],

    [ :must_have_index, {columns: ["symbol"], unique: true}],
  ]

  has_many :members,
           class_name: '::Ygg::Ml::List::Member',
           dependent: :destroy

  has_many :addresses,
           class_name: '::Ygg::Ml::Address',
           through: :members

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  class Member < Ygg::BasicModel
    self.table_name = 'ml.list_members'

    belongs_to :list,
               class_name: '::Ygg::Ml::List'

    belongs_to :address,
               class_name: '::Ygg::Ml::Address'

    belongs_to :owner,
               polymorphic: true,
               optional: true

    define_default_log_controller(self)
  end

  def label
    name
  end

  def summary
    "#{name} - #{descr}"
  end
end

end
end
