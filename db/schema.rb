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

ActiveRecord::Schema.define(version: 20140201190236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "teams", force: true do |t|
    t.integer "salary"
    t.text    "name"
    t.integer "watches", default: 0
    t.integer "user_id"
    t.integer "points",  default: 0
  end

  add_index "teams", ["user_id"], name: "index_teams_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "videos", force: true do |t|
    t.integer  "salary"
    t.integer  "initial_watches"
    t.integer  "watches"
    t.string   "yt_id"
    t.text     "description"
    t.datetime "uploaded_at"
    t.text     "author"
    t.string   "embed_html5"
    t.integer  "team_id"
    t.text     "title"
    t.text     "thumbnail"
  end

  add_index "videos", ["team_id"], name: "index_videos_on_team_id", using: :btree

  create_table "watch_updates", force: true do |t|
    t.integer  "video_id"
    t.integer  "watches"
    t.datetime "created_at"
  end

  add_index "watch_updates", ["video_id"], name: "index_watch_updates_on_video_id", using: :btree

end
