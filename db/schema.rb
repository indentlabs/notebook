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

ActiveRecord::Schema.define(version: 20161014223701) do

  create_table "archenemyships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "archenemy_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "best_friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "best_friend_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "birthings", force: :cascade do |t|
    t.integer  "character_id"
    t.integer  "birthplace_id"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "capital_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "capital_city_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string   "name",             null: false
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
    t.text     "notes"
    t.text     "private_notes"
    t.integer  "user_id"
    t.integer  "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "privacy"
    t.string   "archetype"
    t.string   "aliases"
    t.string   "motivations"
    t.string   "flaws"
    t.string   "talents"
    t.string   "hobbies"
    t.string   "personality_type"
  end

  create_table "childrenships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "child_id"
  end

  create_table "creatures", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "type_of"
    t.string   "other_names"
    t.integer  "universe_id"
    t.string   "color"
    t.string   "shape"
    t.string   "size"
    t.string   "notable_features"
    t.string   "materials"
    t.string   "preferred_habitat"
    t.string   "sounds"
    t.string   "strengths"
    t.string   "weaknesses"
    t.string   "spoils"
    t.string   "aggressiveness"
    t.string   "attack_method"
    t.string   "defense_method"
    t.string   "maximum_speed"
    t.string   "food_sources"
    t.string   "migratory_patterns"
    t.string   "reproduction"
    t.string   "herd_patterns"
    t.string   "similar_animals"
    t.string   "symbolisms"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
  end

  create_table "current_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "current_owner_id"
  end

  create_table "fatherships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "father_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",                               null: false
    t.string   "item_type"
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
    t.string   "privacy",        default: "private", null: false
  end

  create_table "largest_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "largest_city_id"
  end

  create_table "location_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "leader_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",                                 null: false
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
    t.string   "privacy",          default: "private", null: false
    t.string   "laws"
    t.string   "climate"
    t.string   "founding_story"
    t.string   "sports"
  end

  create_table "magics", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "type_of"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "visuals"
    t.string   "effects"
    t.string   "positive_effects"
    t.string   "negative_effects"
    t.string   "neutral_effects"
    t.string   "element"
    t.string   "resource_costs"
    t.string   "materials"
    t.string   "skills_required"
    t.string   "limitations"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "maker_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "maker_id"
  end

  create_table "marriages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "spouse_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "motherships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "mother_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "notable_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "notable_city_id"
  end

  create_table "original_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "original_owner_id"
  end

  create_table "ownerships", force: :cascade do |t|
    t.integer  "character_id"
    t.integer  "item_id"
    t.integer  "user_id"
    t.boolean  "favorite"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "past_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "past_owner_id"
  end

  create_table "races", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "body_shape"
    t.string   "skin_colors"
    t.string   "height"
    t.string   "weight"
    t.string   "notable_features"
    t.string   "variance"
    t.string   "clothing"
    t.string   "strengths"
    t.string   "weaknesses"
    t.string   "traditions"
    t.string   "beliefs"
    t.string   "governments"
    t.string   "technologies"
    t.string   "occupations"
    t.string   "economics"
    t.string   "favorite_foods"
    t.string   "notable_events"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "religions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "origin_story"
    t.string   "teachings"
    t.string   "prophecies"
    t.string   "places_of_worship"
    t.string   "worship_services"
    t.string   "obligations"
    t.string   "paradise"
    t.string   "initiation"
    t.string   "rituals"
    t.string   "holidays"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "username",   null: false
    t.string   "password",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "siblingships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "sibling_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "universes", force: :cascade do |t|
    t.string   "name",            null: false
    t.text     "description"
    t.text     "history"
    t.text     "notes"
    t.text     "private_notes"
    t.string   "privacy"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "laws_of_physics"
    t.string   "magic_system"
    t.string   "technologies"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                               null: false
    t.string   "old_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
