#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao
class Airfield < Ygg::PublicModel

class Circuit < Ygg::BasicModel
  self.table_name = 'acao.airfield_circuits'

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "airfield_id", type: :integer, default: nil, null: false}],
    [ :must_have_column, {name: "name", type: :string, limit: 64, null: false}],
    [ :must_have_column, {name: "data", type: :text, null: true}],
    [ :must_have_index, {columns: ["airfield_id"], unique: false}],
    [ :must_have_fk, {to_table: "acao_airfields", column: "airfield_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :airfield,
             class_name: '::Ygg::Acao::Airfield'
end

end
end
end
