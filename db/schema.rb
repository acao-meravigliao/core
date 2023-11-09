# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_28_235158) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_planes", id: :serial, force: :cascade do |t|
    t.integer "plane_id", null: false
    t.string "flying_state", limit: 32
    t.string "towing_state", limit: 32
    t.integer "towed_plane_id"
  end

  create_table "flights", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uuid", limit: 36, null: false
    t.integer "acao_ext_id", null: false
    t.integer "plane_pilot1_id"
    t.integer "plane_pilot2_id"
    t.integer "towplane_pilot1_id"
    t.integer "towplane_pilot2_id"
    t.integer "plane_id"
    t.integer "towplane_id"
    t.datetime "takeoff_at"
    t.datetime "landing_at"
    t.datetime "towplane_landing_at"
    t.integer "tipo_volo_club"
    t.integer "tipo_aereo_aliante"
    t.integer "durata_volo_aereo_minuti"
    t.integer "durata_volo_aliante_minuti"
    t.integer "quota"
    t.decimal "bollini_volo", precision: 14, scale: 6
    t.boolean "check_chiuso"
    t.string "dep", limit: 64
    t.string "arr", limit: 64
    t.integer "num_att"
    t.datetime "data_att"
    t.index ["plane_pilot1_id"], name: "index_flights_on_plane_pilot1_id"
    t.index ["plane_pilot2_id"], name: "index_flights_on_plane_pilot2_id"
    t.index ["towplane_pilot1_id"], name: "index_flights_on_towplane_pilot1_id"
    t.index ["towplane_pilot2_id"], name: "index_flights_on_towplane_pilot2_id"
  end

  create_table "idxc_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "obj_type", limit: 255, null: false
    t.uuid "obj_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.boolean "accessible"
    t.uuid "person_id", null: false
    t.index ["obj_type", "obj_id", "accessible"], name: "index_idxc_entries_on_obj_type_and_obj_id_and_accessible"
    t.index ["obj_type", "obj_id", "person_id"], name: "index_idxc_entries_on_obj_type_and_obj_id_and_person_id", unique: true
    t.index ["obj_type", "obj_id"], name: "index_idxc_entries_on_obj_type_and_obj_id"
    t.index ["person_id"], name: "index_idxc_entries_on_person_id"
  end

  create_table "idxc_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "obj_type", limit: 255, null: false
    t.datetime "updated_at", default: -> { "now()" }
    t.boolean "has_dirty", default: false, null: false
    t.uuid "person_id", null: false
    t.index ["obj_type", "person_id"], name: "index_idxc_statuses_on_obj_type_and_person_id", unique: true
    t.index ["obj_type"], name: "index_idxc_statuses_on_obj_type"
    t.index ["person_id"], name: "index_idxc_statuses_on_person_id"
  end

  create_table "maindb_last_update", id: :serial, force: :cascade do |t|
    t.string "tablename", limit: 32, null: false
    t.datetime "last_update"
  end

  create_table "met_history_entries", id: :serial, force: :cascade do |t|
    t.datetime "ts", null: false
    t.datetime "record_ts", null: false
    t.string "source", limit: 32, null: false
    t.string "variable", limit: 32, null: false
    t.string "value", null: false
    t.index ["source", "variable"], name: "met_history_entries_source_variable_idx"
    t.index ["ts", "source", "variable"], name: "met_history_entries_ts_source_variable_idx"
    t.index ["ts"], name: "met_history_entries_ts_idx"
  end

  create_table "met_history_entries2", id: false, force: :cascade do |t|
    t.integer "id"
    t.datetime "ts"
    t.datetime "record_ts"
    t.string "source", limit: 32
    t.string "variable", limit: 32
    t.string "value"
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.integer "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "radacct", primary_key: "radacctid", force: :cascade do |t|
    t.string "acctsessionid", limit: 64, null: false
    t.string "acctuniqueid", limit: 32, null: false
    t.string "username", limit: 253
    t.string "groupname", limit: 253
    t.string "realm", limit: 64
    t.inet "nasipaddress", null: false
    t.string "nasportid", limit: 15
    t.string "nasporttype", limit: 32
    t.datetime "acctstarttime"
    t.datetime "acctstoptime"
    t.bigint "acctsessiontime"
    t.string "acctauthentic", limit: 32
    t.string "connectinfo_start", limit: 50
    t.string "connectinfo_stop", limit: 50
    t.bigint "acctinputoctets"
    t.bigint "acctoutputoctets"
    t.string "calledstationid", limit: 50
    t.string "callingstationid", limit: 50
    t.string "acctterminatecause", limit: 32
    t.string "servicetype", limit: 32
    t.string "xascendsessionsvrkey", limit: 10
    t.string "framedprotocol", limit: 32
    t.inet "framedipaddress"
    t.integer "acctstartdelay"
    t.integer "acctstopdelay"
    t.index ["acctstarttime", "username"], name: "radacct_start_user_idx"
    t.index ["username", "nasipaddress", "acctsessionid"], name: "radacct_active_user_idx", where: "(acctstoptime IS NULL)"
  end

  create_table "radcheck", id: :serial, force: :cascade do |t|
    t.string "username", limit: 64, default: "", null: false
    t.string "attribute", limit: 64, default: "", null: false
    t.string "op", limit: 2, default: "==", null: false
    t.string "value", limit: 253, default: "", null: false
    t.index ["username", "attribute"], name: "radcheck_username"
  end

  create_table "radgroupcheck", id: :serial, force: :cascade do |t|
    t.string "groupname", limit: 64, default: "", null: false
    t.string "attribute", limit: 64, default: "", null: false
    t.string "op", limit: 2, default: "==", null: false
    t.string "value", limit: 253, default: "", null: false
    t.index ["groupname", "attribute"], name: "radgroupcheck_groupname"
  end

  create_table "radgroupreply", id: :serial, force: :cascade do |t|
    t.string "groupname", limit: 64, default: "", null: false
    t.string "attribute", limit: 64, default: "", null: false
    t.string "op", limit: 2, default: "=", null: false
    t.string "value", limit: 253, default: "", null: false
    t.index ["groupname", "attribute"], name: "radgroupreply_groupname"
  end

  create_table "radpostauth", force: :cascade do |t|
    t.string "username", limit: 253, null: false
    t.string "pass", limit: 128
    t.string "reply", limit: 32
    t.string "calledstationid", limit: 50
    t.string "callingstationid", limit: 50
    t.datetime "authdate", default: "2016-02-21 10:29:59", null: false
  end

  create_table "radreply", id: :serial, force: :cascade do |t|
    t.string "username", limit: 64, default: "", null: false
    t.string "attribute", limit: 64, default: "", null: false
    t.string "op", limit: 2, default: "=", null: false
    t.string "value", limit: 253, default: "", null: false
    t.index ["username", "attribute"], name: "radreply_username"
  end

  create_table "radusergroup", id: false, force: :cascade do |t|
    t.string "username", limit: 64, default: "", null: false
    t.string "groupname", limit: 64, default: "", null: false
    t.integer "priority", default: 0, null: false
    t.index ["username"], name: "radusergroup_username"
  end

  create_table "str_channel_variants", id: :serial, force: :cascade do |t|
    t.integer "channel_id", null: false
    t.string "symbol", limit: 32, null: false
    t.string "stream_url", null: false
    t.integer "width"
    t.integer "height"
    t.integer "bandwidth"
    t.string "name", limit: 32
    t.boolean "autostart", default: true, null: false
    t.boolean "enabled", default: true, null: false
    t.integer "version", default: 0, null: false
  end

  create_table "str_channels", id: :serial, force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.string "name"
    t.string "descr"
    t.string "poster"
    t.string "symbol", limit: 32, null: false
    t.integer "agent_id"
    t.integer "version", default: 0, null: false
    t.boolean "condemned", default: false, null: false
    t.index ["agent_id"], name: "index_str_channels_on_agent_id"
    t.index ["uuid"], name: "index_str_channels_on_uuid", unique: true
  end

  create_table "trk_contest_days", id: :serial, force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "contest_id", null: false
    t.date "date", null: false
    t.boolean "task", null: false
    t.boolean "valid_day", null: false
    t.text "cuc_file"
  end

  create_table "trk_contests", id: :serial, force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 32, null: false
    t.text "display_name", null: false
    t.integer "data_delay"
    t.integer "utc_offset", null: false
    t.string "country_code", limit: 2, null: false
    t.text "site", null: false
    t.float "lat", null: false
    t.float "lng", null: false
    t.float "alt", null: false
    t.date "from_date", null: false
    t.date "to_date", null: false
    t.index ["name"], name: "trk_contests_name_idx", unique: true
    t.index ["uuid"], name: "trk_contests_uuid_idx", unique: true
  end

  create_table "trk_day_aircrafts", id: :integer, default: -> { "nextval('trk_day_planes_id_seq'::regclass)" }, force: :cascade do |t|
    t.date "day", null: false
    t.integer "aircraft_id", null: false
    t.index ["aircraft_id"], name: "trk_day_planes_plane_id_idx"
    t.index ["day"], name: "trk_day_planes_day_idx"
  end

  add_foreign_key "str_channel_variants", "str_channels", column: "channel_id", name: "str_channel_variants_cam_id_fkey"
end
