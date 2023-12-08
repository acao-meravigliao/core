#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class KeyStore < Ygg::PublicModel
  self.table_name = 'ca.key_stores'
#  self.abstract_class = true
  self.inheritance_column = :sti_type

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "sti_type", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "remote_agent_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "local_directory", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["symbol"], unique: true}],
    [ :must_have_index, {columns: ["remote_agent_id"], unique: false}],

    [ :must_have_fk, {to_table: "core_agents", column: "remote_agent_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :model_pair_locations,
           class_name: '::Ygg::Ca::KeyPair::Location',
           foreign_key: :store_id

  has_many :model_pairs,
           class_name: '::Ygg::Ca::KeyPair',
           through: :model_pair_locations,
           source: :pair
end

end
end
