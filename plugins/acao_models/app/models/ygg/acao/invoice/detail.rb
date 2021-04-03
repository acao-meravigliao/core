#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
class Invoice < Ygg::PublicModel

class Detail < Ygg::BasicModel
  self.table_name = 'acao.invoice_details'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, null: false, default_function: 'gen_random_uuid()' }],
    [ :must_have_column, {name: "invoice_id", type: :uuid, default: nil, null: false}],
    [ :must_have_column, {name: "count", type: :integer, default: nil, null: false}],
    [ :must_have_column, {name: "price", type: :decimal, default: nil, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "service_type_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "data", type: :text, default: nil, null: true}],

    [ :must_have_index, {columns: ["invoice_id"], unique: false}],
    [ :must_have_index, {columns: ["service_type_id"], unique: false}],

    [ :must_have_fk, {to_table: "acao_invoices", column: "invoice_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "acao_service_types", column: "service_type_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :invoice,
             class_name: '::Ygg::Acao::Invoice'

  belongs_to :service_type,
             class_name: '::Ygg::Acao::ServiceType',
             optional: true

  has_one :membership,
          class_name: '::Ygg::Acao::Membership',
          foreign_key: 'invoice_detail_id'

  has_one :member_service,
          class_name: '::Ygg::Acao::MemberService',
          foreign_key: 'invoice_detail_id',
          dependent: :destroy

  has_meta_class

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
end
