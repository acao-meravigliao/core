#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module I18n

class Phrase < Ygg::PublicModel
  self.table_name = 'i18n.phrases'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "phrase", type: :string, default: nil, null: false}],

    [ :must_have_index, {columns: ["phrase"], unique: true}],
  ]

  has_many :translations,
           class_name: '::Ygg::I18n::Phrase::Translation',
           dependent: :destroy,
           embedded: true,
           autosave: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
