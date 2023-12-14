#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class Ca < Ygg::PublicModel
  self.table_name = 'ca.cas'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, limit: 64, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "key_pair_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "certificate_id", type: :integer, default: nil, limit: 4, null: true}],

    [ :must_have_index, {columns: ["key_pair_id"], unique: false}],
    [ :must_have_index, {columns: ["certificate_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_key_pairs", column: "key_pair_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "ca_certificates", column: "certificate_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  belongs_to :key_pair,
             class_name: '::Ygg::Ca::KeyPair',
             optional: true

  belongs_to :certificate,
             class_name: '::Ygg::Ca::Certificate'

  def summary
    "#{name} - #{descr}"
  end
end

end
end
