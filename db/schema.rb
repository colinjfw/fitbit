# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150712204823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "date"
    t.time     "start_time"
    t.text     "series",                        array: true
    t.integer  "min_in_bed"
    t.integer  "min_awake"
    t.integer  "min_asleep"
    t.integer  "min_fall_asleep"
    t.integer  "min_restless"
    t.integer  "awakening_count"
    t.json     "heart_rate_zones"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "data", ["date"], name: "index_data_on_date", using: :btree
  add_index "data", ["user_id"], name: "index_data_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "refresh_token"
    t.string   "access_token"
    t.string   "name"
    t.string   "email"
    t.string   "password_hash"
    t.string   "csrf_token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "expiry"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token", using: :btree
  add_index "users", ["refresh_token"], name: "index_users_on_refresh_token", using: :btree

  add_foreign_key "data", "users"
end
