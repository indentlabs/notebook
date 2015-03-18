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

ActiveRecord::Schema.define(version: 20140713043535) do

  create_table "characters", force: true do |t|
    t.string   "name",            null: false
    t.string   "role"
    t.string   "gender"
    t.string   "age"
    t.string   "height"
    t.string   "weight"
    t.string   "haircolor"
    t.string   "hairstyle"
    t.string   "facialhair"
    t.string   "eyecolor"
    t.string   "race"
    t.string   "skintone"
    t.string   "bodytype"
    t.string   "identmarks"
    t.text     "bestfriend"
    t.text     "religion"
    t.text     "politics"
    t.text     "prejudices"
    t.text     "occupation"
    t.text     "pets"
    t.text     "mannerisms"
    t.text     "birthday"
    t.text     "birthplace"
    t.text     "education"
    t.text     "background"
    t.string   "fave_color"
    t.string   "fave_food"
    t.string   "fave_possession"
    t.string   "fave_weapon"
    t.string   "fave_animal"
    t.text     "father"
    t.text     "mother"
    t.text     "spouse"
    t.text     "siblings"
    t.text     "archenemy"
    t.text     "notes"
    t.text     "private_notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment", force: true do |t|
    t.string   "name",           null: false
    t.string   "equip_type"
    t.text     "description"
    t.string   "weight"
    t.string   "original_owner"
    t.string   "current_owner"
    t.text     "made_by"
    t.text     "materials"
    t.string   "year_made"
    t.text     "magic"
    t.text     "notes"
    t.text     "private_notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.string   "name",                 null: false
    t.text     "words"
    t.string   "established_year"
    t.string   "established_location"
    t.text     "characters"
    t.text     "locations"
    t.text     "notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name",             null: false
    t.string   "type_of"
    t.text     "description"
    t.string   "map_file_name"
    t.string   "map_content_type"
    t.integer  "map_file_size"
    t.datetime "map_updated_at"
    t.string   "population"
    t.string   "language"
    t.string   "currency"
    t.string   "motto"
    t.text     "capital"
    t.text     "largest_city"
    t.text     "notable_cities"
    t.text     "area"
    t.text     "crops"
    t.text     "located_at"
    t.string   "established_year"
    t.text     "notable_wars"
    t.text     "notes"
    t.text     "private_notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "magics", force: true do |t|
    t.string   "name",          null: false
    t.string   "type_of"
    t.text     "manifestation"
    t.text     "symptoms"
    t.string   "element"
    t.string   "diety"
    t.text     "harmfulness"
    t.text     "helpfulness"
    t.text     "neutralness"
    t.text     "resource"
    t.text     "skill_level"
    t.text     "limitations"
    t.text     "notes"
    t.text     "private_notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "username",   null: false
    t.string   "password",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "universes", force: true do |t|
    t.string   "name",          null: false
    t.text     "description"
    t.text     "history"
    t.text     "notes"
    t.text     "private_notes"
    t.string   "privacy"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.string   "password",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
