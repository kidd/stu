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

ActiveRecord::Schema.define(version: 20140613093336) do

  create_table "scrobbles", force: true do |t|
    t.string   "user"
    t.datetime "scrobbled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "track_id"
    t.float    "lat"
    t.float    "lon"
  end

  add_index "scrobbles", ["track_id"], name: "index_scrobbles_on_track_id"

  create_table "tracks", force: true do |t|
    t.string   "mbid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "genre"
  end

end
