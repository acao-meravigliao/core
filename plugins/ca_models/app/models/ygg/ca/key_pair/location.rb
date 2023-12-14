module Ygg
module Ca
class KeyPair < Ygg::PublicModel

class Location < Ygg::BasicModel
  belongs_to :pair,
             class_name: '::Ygg::Ca::KeyPair'

  belongs_to :store,
             class_name: '::Ygg::Ca::KeyStore'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "pair_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "identifier", type: :string, default: nil, limit: 64, null: true}],
    [ :must_have_column, {name: "store_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "path", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["store_id"], unique: false}],
    [ :must_have_index, {columns: ["pair_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_key_stores", column: "store_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "ca_key_pairs", column: "pair_id", primary_key: "id", on_delete: :cascade, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
end
