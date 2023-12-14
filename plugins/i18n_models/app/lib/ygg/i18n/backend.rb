#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module I18n

class Backend
  include ::I18n::Backend::Base
  include ::I18n::Backend::Cache

  def lookup(locale, key, scope = [], options = {})
    check!
    @translations[locale.to_s] && @translations[locale.to_s][key.to_s]
  end

  def reload!
    @translations = nil
    @locales = nil
  end

  def load!
    @translations = {}
    @locales = Set.new

    Ygg::I18n::Phrase::Translation.joins(:phrase, :language).includes(:phrase,:language).all.each do |t|
      @locales << t.language.iso_639_1
      @translations[t.language.iso_639_1] ||= {}

      if t.value.start_with?('[')
        @translations[t.language.iso_639_1][t.phrase.phrase] = YAML.parse(t.value).to_ruby rescue nil
      else
        @translations[t.language.iso_639_1][t.phrase.phrase] = t.value
      end
    end

  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
    puts "Error initializing i18n: #{e}"
  end

  def check!
    Rails.application.executor.wrap do
      load! if @translations.nil?
    end
  end

  def available_locales
    check!
    @locales.to_a
  end
end

end
end
