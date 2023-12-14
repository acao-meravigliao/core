#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Address < Ygg::PublicModel
  self.table_name = 'ml.addresses'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "addr", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "addr_type", type: :string, default: nil, limit: 32, null: false}],
    [ :must_have_column, {name: "failed_deliveries", type: :integer, default: 0, limit: 4, null: false}],

    [ :must_have_index, {columns: ["addr_type","addr"], unique: true}],
  ]

  validates :addr, presence: true
  validates :addr_type, presence: true

  has_many :list_members,
           class_name: '::Ygg::Ml::List::Member',
           dependent: :destroy

  has_many :lists,
           class_name: '::Ygg::Ml::List',
           through: :list_members

  has_many :messages,
           class_name: '::Ygg::Ml::Msg::Rcpt',
           dependent: :destroy
end

end
end
