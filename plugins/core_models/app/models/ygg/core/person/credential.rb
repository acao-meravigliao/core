#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'openssl'
require 'base64'

module Ygg
module Core
class Person

class Credential < Ygg::YggModel
  self.table_name = 'core.person_credentials'
  self.inheritance_column = :sti_type
  #self.abstract_class = true

  belongs_to :person,
             class_name: 'Ygg::Core::Person',
             foreign_key: 'person_id',
             embedded_in: true

  validates :fqda, presence: true
  validates :data, presence: true

  if defined? PgSearch
    include PgSearch::Model

    pg_search_scope(
      :search_full_text,
      against: [:fqda],
      using: {
        tsearch: {prefix: true, any_word: true},
        dmetaphone: {any_word: true},
        trigram: {threshold: 0.1}
      }
    )
  end

  define_default_log_controller(self)

  def confidence
    raise "confidence method should have been redefined in Credential subclass"
  end

  def to_s
    fqda
  end

  def label
    fqda
  end

  def summary
    fqda
  end
end

end
end
end
