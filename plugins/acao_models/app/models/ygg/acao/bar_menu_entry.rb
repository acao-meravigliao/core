#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class BarMenuEntry < Ygg::PublicModel
  self.table_name = 'acao.bar_menu_entries'
  self.inheritance_column = false

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, limit: 255, null: false}],
    [ :must_have_column, {name: "price", type: :decimal, default: nil, precision: 14, scale: 6, null: false}],
    [ :must_have_column, {name: "on_sale", type: :boolean, default: false, null: false}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_meta_class
end

end
end
