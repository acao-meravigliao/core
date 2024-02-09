class AddSyncTable < ActiveRecord::Migration[6.1]
  def change
    create_table "sync_status", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "symbol", limit: 255, null: false
      t.datetime "synced_at", default: -> { "now()" }, null: false
    end
  end
end
