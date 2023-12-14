#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Group < Ygg::PublicModel
  self.table_name = 'core.groups'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'name', type: :string } ],
    [ :must_have_column, { name: 'description', type: :text } ],
    [ :must_have_column, { name: 'symbol', type: :string } ],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :group_members,
           :class_name => '::Ygg::Core::Group::Member',
           :embedded => true,
           :autosave => true,
           :dependent => :destroy

  has_many :people,
           :class_name => '::Ygg::Core::Person',
           :through => :group_members

  validates :name, presence: true

  if defined? PgSearch
    include PgSearch::Model
    multisearchable against: [ :name, :description ]

    pg_search_scope :search, ignoring: :accents, against: {
      name: 'A',
      description: 'A',
    }, using: {
      tsearch: {},
      trigram: { only: [ :name ] },
    }
  end

  def label
    name
  end

  def summary
    name
  end
end

end
end
