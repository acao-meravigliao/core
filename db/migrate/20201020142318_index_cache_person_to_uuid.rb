class IndexCachePersonToUuid < ActiveRecord::Migration[6.0]
  def up
    drop_table :core_index_cache_statuses
    drop_table :core_index_cache_entries
    drop_table :core_index_cache_uuid_entries

    create_table "idxc_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "obj_type", limit: 255, null: false
      t.uuid "obj_id", null: false
      t.datetime "created_at", default: -> { "now()" }, null: false
      t.boolean "accessible"
      t.uuid "person_id", null: false
      t.index ["obj_type", "obj_id", "person_id"], unique: true
      t.index ["obj_type", "obj_id", "accessible"]
      t.index ["obj_type", "obj_id"]
      t.index ["person_id"]
    end

    create_table "idxc_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "obj_type", limit: 255, null: false
      t.datetime "updated_at", default: -> { "now()" }
      t.boolean "has_dirty", default: false, null: false
      t.uuid "person_id", null: false
      t.index ["obj_type", "person_id"], unique: true
      t.index ["obj_type"]
      t.index ["person_id"]
    end
  end
end
