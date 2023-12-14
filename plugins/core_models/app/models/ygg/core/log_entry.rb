#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class LogEntry < ActiveRecord::Base
  self.table_name = 'core.log_entries'

  # Cannot be a BasicModel otherwise we include Loggable and thus we log the log too so we have to include all the needed mixins
  # by hand
  include Ygg::Core::HasPornMigration

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'timestamp', type: :datetime, null: false } ],
    [ :must_have_column, { name: 'transaction_id', type: :uuid } ],
    [ :must_have_column, { name: 'person_id', type: :integer } ],
    [ :must_have_column, { name: 'description', type: :text, null: false } ],
    [ :must_have_column, { name: 'notes', type: :text } ],
    [ :must_have_column, { name: 'extra_info', type: :text } ],
    [ :must_have_column, { name: 'http_session_id', type: :integer } ],
  ]

  belongs_to :person,
             class_name: '::Ygg::Core::Person',
             optional: true

  belongs_to :http_session,
             class_name: '::Ygg::Core::HttpSession',
             optional: true

  has_many :details,
           class_name: '::Ygg::Core::LogEntry::Detail',
           dependent: :destroy,
           embedded: true,
           autosave: true

  validates :description, presence: true

  after_initialize do
    if new_record?
      self.timestamp = Time.now
    end
  end

  def summary
    id.to_s
  end
end

end
end
