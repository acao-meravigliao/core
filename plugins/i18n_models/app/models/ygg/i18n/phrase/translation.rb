module Ygg
module I18n
class Phrase < Ygg::PublicModel

class Translation < Ygg::YggModel
  self.table_name = 'i18n.translations'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "phrase_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "language_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "value", type: :text, default: nil, null: false}],

    [ :must_have_index, {columns: ["phrase_id"], unique: false}],
    [ :must_have_index, {columns: ["language_id"], unique: false}],
    [ :must_have_index, {columns: ["language_id","phrase_id"], unique: true}],

    [ :must_have_fk, {to_table: "i18n_languages", column: "language_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "i18n_phrases", column: "phrase_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :phrase,
             class_name: '::Ygg::I18n::Phrase'

  belongs_to :language,
             class_name: '::Ygg::I18n::Language'

  define_default_log_controller(self)
end

end
end
end
