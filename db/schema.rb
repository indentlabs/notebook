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
    t.text    "name"
    t.text    "role"
    t.text    "gender"
    t.text    "age"
    t.text    "height"
    t.text    "weight"
    t.text    "race"
    t.text    "haircolor"
    t.text    "hairstyle"
    t.text    "facialhair"
    t.text    "eyecolor"
    t.text    "skintone"
    t.text    "bodytype"
    t.text    "identmarks"
    t.text    "bestfriend"
    t.text    "religion"
    t.text    "politics"
    t.text    "prejudices"
    t.text    "occupation"
    t.text    "mannerisms"
    t.text    "birthday"
    t.text    "birthplace"
    t.text    "education"
    t.text    "fave_color"
    t.text    "fave_food"
    t.text    "fave_possession"
    t.text    "fave_weapon"
    t.text    "fave_animal"
    t.text    "father"
    t.text    "mother"
    t.text    "spouse"
    t.text    "siblings"
    t.text    "archenemy"
    t.integer "user_id"
    t.integer "universe_id"
    t.text    "notes"
    t.text    "private_notes"
    t.text    "pets"
    t.text    "background"
  end

  create_table "equipment", force: true do |t|
    t.text    "description"
    t.text    "equip_type"
    t.text    "made_by"
    t.text    "magic"
    t.text    "materials"
    t.text    "name"
    t.text    "original_owner"
    t.text    "weight"
    t.integer "user_id"
    t.integer "universe_id"
    t.text    "current_owner"
    t.text    "notes"
    t.text    "private_notes"
    t.text    "year_made"
  end

  create_table "languages", force: true do |t|
    t.text    "name"
    t.text    "words"
    t.text    "established_year"
    t.text    "established_location"
    t.text    "characters"
    t.text    "locations"
    t.text    "notes"
    t.integer "user_id"
    t.integer "universe_id"
  end

  create_table "locations", force: true do |t|
    t.text    "name"
    t.text    "type_of"
    t.text    "located_at"
    t.text    "population"
    t.text    "language"
    t.text    "currency"
    t.text    "motto"
    t.text    "capital"
    t.text    "largest_city"
    t.text    "notable_cities"
    t.text    "area"
    t.text    "crops"
    t.text    "established_year"
    t.text    "notable_wars"
    t.text    "description"
    t.integer "universe_id"
    t.integer "user_id"
    t.text    "notes"
    t.text    "private_notes"
    t.text    "map_file_name"
    t.text    "map_content_size"
    t.integer "map_file_size"
    t.integer "map_updated_at"
  end

  create_table "magics", force: true do |t|
    t.text    "name"
    t.text    "type_of"
    t.text    "manifestation"
    t.text    "symptoms"
    t.text    "element"
    t.text    "diety"
    t.text    "harmfulness"
    t.text    "helpfulness"
    t.text    "neutralness"
    t.text    "resource"
    t.text    "skill_level"
    t.text    "limitations"
    t.integer "user_id"
    t.text    "notes"
    t.text    "private_notes"
    t.integer "universe_id"
  end

  create_table "sessions", force: true do |t|
    t.string   "username",   null: false
    t.string   "password",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "universes", force: true do |t|
    t.text    "name"
    t.text    "description"
    t.text    "history"
    t.text    "notes"
    t.text    "private_notes"
    t.text    "privacy"
    t.integer "user_id"
  end

  create_table "users", force: true do |t|
    t.text "name"
    t.text "email"
    t.text "password"
  end

end
