#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module I18n

class Language < Ygg::PublicModel
  self.table_name = 'i18n.languages'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "iso_639_1", type: :string, default: nil, limit: 2, null: true}],
    [ :must_have_column, {name: "iso_639_3", type: :string, default: nil, limit: 3, null: false}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: false}],

    [ :must_have_index, {columns: ["iso_639_1"], unique: false}],
    [ :must_have_index, {columns: ["iso_639_3"], unique: true}],
  ]

  has_many :translations,
           class_name: '::Ygg::I18n::Phrase::Translation'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def import(filename:)
    data = YAML.load(File.read(filename))

    transaction do
      data.each do |phrase_name,translation_value|
        phrase = Ygg::I18n::Phrase.find_by(phrase: phrase_name)
        if !phrase
          phrase = Ygg::I18n::Phrase.create!(phrase: phrase_name)
        end

        translation = phrase.translations.find_by(language_id: id)
        if translation
          translation.value = translation_value
          translation.save!
        else
          phrase.translations << Ygg::I18n::Phrase::Translation.new(language_id: id, value: translation_value)
        end
      end
    end
  end

  def export
    YAML.dump(Hash[translations.joins(:phrase).includes(:phrase).order('i18n_phrases.phrase').map { |x| [ x.phrase.phrase, x.value ] }])
  end

  def self.export(filename: 'translations')
    res = Hash[Ygg::I18n::Phrase.includes(:translations).includes(translations: :language).order('phrase').all.map { |x|
      [ x.phrase, Hash[x.translations.map { |t| [ t.language.iso_639_1, t.value ] }.sort_by { |t| t[0] }] ]
    }]

    File.write(filename, YAML.dump(res))
  end

  def self.import(filename: 'translations')
    data = YAML.load(File.read(filename))

    langs = {}

    transaction do
      data.each do |phrase_name,translations|
        translations.each do |translation_lang,translation|
          lang = langs[translation_lang]
          if !lang && !lang.eql?(false)
            lang = Ygg::I18n::Language.find_by(iso_639_1: translation_lang)
            langs[translation_lang] = lang || false
          end

          if lang
            phrase = Ygg::I18n::Phrase.find_or_create_by(phrase: phrase_name)
            t = Ygg::I18n::Phrase::Translation.find_or_create_by(language: lang, phrase: phrase) do |tran|
              tran.value = translation
            end

            t.value = translation
            t.save!
          end
        end
      end
    end
  end
end

end
end
