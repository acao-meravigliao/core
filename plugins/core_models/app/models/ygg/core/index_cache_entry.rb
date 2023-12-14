#
# Copyright (C) 2013-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class IndexCacheEntry < ActiveRecord::Base
  self.table_name = 'idxc_entries'

  include Ygg::Core::HasPornMigration
  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :id, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'obj_type', type: :string, null: false } ],
    [ :must_have_column, { name: 'obj_id', type: :uuid, null: false } ],
    [ :must_have_column, { name: 'person_id', type: :integer, null: false } ],
    [ :must_have_column, { name: 'created_at', type: :datetime } ],
    [ :must_have_index, {:columns=>["obj_type", "obj_id"], :unique=>false, }],
    [ :must_have_index, {:columns=>["obj_type", "obj_id", "person_id"], :unique=>true, name: 'core.index_cache_uuid_entries_uniq' }],
    [ :must_have_index, {:columns=>["person_id"], :unique=>false, }],
    [ :must_have_fk, {:to_table=>"core.people", :column=>"person_id", :primary_key=>"id", :on_delete=>nil, :on_update=>nil}],
  ]

  belongs_to :obj,
             polymorphic: true

  belongs_to :person,
             class_name: '::Ygg::Core::Person'
end

end
end
