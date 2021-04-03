#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class TokenTransaction < Ygg::PublicModel
  self.table_name = 'acao.token_transactions'

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :integer, null: false, limit: 4 } ],
    [ :must_have_column, { name: "uuid", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "aircraft_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "recorded_at", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "prev_credit", type: :decimal, default: nil, precision: 14, scale: 6, null: true}],
    [ :must_have_column, {name: "credit", type: :decimal, default: nil, precision: 14, scale: 6, null: true}],
    [ :must_have_column, {name: "amount", type: :decimal, default: nil, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "session_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_index, {columns: ["uuid"], unique: true}],
    [ :must_have_index, {columns: ["recorded_at"], unique: false}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["aircraft_id"], unique: false}],
    [ :must_have_index, {columns: ["session_id"], unique: false}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "core_sessions", column: "session_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_aircrafts", column: "aircraft_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :person,
             class_name: '::Ygg::Core::Person'

  belongs_to :aircraft,
             class_name: '::Ygg::Acao::Aircraft',
             optional: true

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

end

end
end
