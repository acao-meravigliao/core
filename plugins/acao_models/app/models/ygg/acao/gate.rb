# frozen_string_literal: true
#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Gate < Ygg::PublicModel
  self.table_name = 'acao.gates'

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "agent_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_index, {columns: ["agent_id"], unique: false}],
    [ :must_have_fk, {to_table: "core_agents", column: "agent_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :agent,
             class_name: '::Ygg::Core::Agent',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
