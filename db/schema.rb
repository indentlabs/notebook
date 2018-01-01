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

ActiveRecord::Schema.define(version: 20171231235747) do

  create_table "archenemyships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "archenemy_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "artifactships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "artifact_id"
    t.integer "user_id"
  end

  create_table "attribute_categories", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "entity_type"
    t.string   "name",        null: false
    t.string   "label",       null: false
    t.string   "icon"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attribute_categories", ["entity_type"], name: "index_attribute_categories_on_entity_type"
  add_index "attribute_categories", ["name"], name: "index_attribute_categories_on_name"

  create_table "attribute_fields", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "attribute_category_id",                     null: false
    t.string   "name",                                      null: false
    t.string   "label",                                     null: false
    t.string   "field_type",                                null: false
    t.text     "description"
    t.string   "privacy",               default: "private", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attribute_fields", ["user_id", "name"], name: "index_attribute_fields_on_user_id_and_name"

  create_table "attributes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "attribute_field_id"
    t.string   "entity_type",                            null: false
    t.integer  "entity_id",                              null: false
    t.text     "value"
    t.string   "privacy",            default: "private", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attributes", ["user_id", "entity_type", "entity_id"], name: "index_attributes_on_user_id_and_entity_type_and_entity_id"

  create_table "best_friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "best_friend_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "billing_plans", force: :cascade do |t|
    t.string   "name"
    t.string   "stripe_plan_id"
    t.integer  "monthly_cents"
    t.boolean  "available"
    t.boolean  "allows_core_content"
    t.boolean  "allows_extended_content"
    t.boolean  "allows_collective_content"
    t.boolean  "allows_collaboration"
    t.integer  "universe_limit"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "bonus_bandwidth_kb",        default: 0
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

  create_table "character_love_interests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "love_interest_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "character_love_interests", ["character_id"], name: "index_character_love_interests_on_character_id"
  add_index "character_love_interests", ["user_id"], name: "index_character_love_interests_on_user_id"

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
    t.datetime "deleted_at"
  end

  add_index "characters", ["deleted_at"], name: "index_characters_on_deleted_at"

  create_table "childrenships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "child_id"
  end

  create_table "content_change_events", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "changed_fields"
    t.integer  "content_id"
    t.string   "content_type"
    t.string   "action"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "content_change_events", ["user_id"], name: "index_content_change_events_on_user_id"

  create_table "contributors", force: :cascade do |t|
    t.integer  "universe_id"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "contributors", ["universe_id"], name: "index_contributors_on_universe_id"
  add_index "contributors", ["user_id"], name: "index_contributors_on_user_id"

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.integer  "universe_id"
    t.string   "population"
    t.string   "currency"
    t.string   "laws"
    t.string   "sports"
    t.string   "area"
    t.string   "crops"
    t.string   "climate"
    t.string   "founding_story"
    t.string   "established_year"
    t.string   "notable_wars"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.string   "privacy"
    t.integer  "user_id"
  end

  add_index "countries", ["universe_id"], name: "index_countries_on_universe_id"
  add_index "countries", ["user_id"], name: "index_countries_on_user_id"

  create_table "country_creatures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "creature_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "country_creatures", ["country_id"], name: "index_country_creatures_on_country_id"
  add_index "country_creatures", ["creature_id"], name: "index_country_creatures_on_creature_id"
  add_index "country_creatures", ["user_id"], name: "index_country_creatures_on_user_id"

  create_table "country_floras", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "country_floras", ["country_id"], name: "index_country_floras_on_country_id"
  add_index "country_floras", ["flora_id"], name: "index_country_floras_on_flora_id"
  add_index "country_floras", ["user_id"], name: "index_country_floras_on_user_id"

  create_table "country_landmarks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "landmark_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "country_landmarks", ["country_id"], name: "index_country_landmarks_on_country_id"
  add_index "country_landmarks", ["landmark_id"], name: "index_country_landmarks_on_landmark_id"
  add_index "country_landmarks", ["user_id"], name: "index_country_landmarks_on_user_id"

  create_table "country_languages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "country_languages", ["country_id"], name: "index_country_languages_on_country_id"
  add_index "country_languages", ["language_id"], name: "index_country_languages_on_language_id"
  add_index "country_languages", ["user_id"], name: "index_country_languages_on_user_id"

  create_table "country_locations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "country_locations", ["country_id"], name: "index_country_locations_on_country_id"
  add_index "country_locations", ["location_id"], name: "index_country_locations_on_location_id"
  add_index "country_locations", ["user_id"], name: "index_country_locations_on_user_id"

  create_table "country_religions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "religion_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "country_religions", ["country_id"], name: "index_country_religions_on_country_id"
  add_index "country_religions", ["religion_id"], name: "index_country_religions_on_religion_id"
  add_index "country_religions", ["user_id"], name: "index_country_religions_on_user_id"

  create_table "country_towns", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "country_towns", ["country_id"], name: "index_country_towns_on_country_id"
  add_index "country_towns", ["town_id"], name: "index_country_towns_on_town_id"
  add_index "country_towns", ["user_id"], name: "index_country_towns_on_user_id"

  create_table "creature_relationships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "creature_id"
    t.integer  "related_creature_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
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
    t.string   "notes"
    t.string   "private_notes"
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "creatures", ["deleted_at"], name: "index_creatures_on_deleted_at"

  create_table "current_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "current_owner_id"
  end

  create_table "deityships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "deity_id"
    t.integer "user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "documents", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "documents", ["user_id"], name: "index_documents_on_user_id"

  create_table "famous_figureships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "race_id"
    t.integer "famous_figure_id"
  end

  create_table "fatherships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "character_id"
    t.integer  "father_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "flora_eaten_bies", force: :cascade do |t|
    t.integer  "flora_id"
    t.integer  "creature_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "flora_locations", force: :cascade do |t|
    t.integer  "flora_id"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "flora_magical_effects", force: :cascade do |t|
    t.integer  "flora_id"
    t.integer  "magic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flora_relationships", force: :cascade do |t|
    t.integer  "flora_id"
    t.integer  "related_flora_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "floras", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "aliases"
    t.string   "order"
    t.string   "family"
    t.string   "genus"
    t.string   "colorings"
    t.string   "size"
    t.string   "smell"
    t.string   "taste"
    t.string   "fruits"
    t.string   "seeds"
    t.string   "nuts"
    t.string   "berries"
    t.string   "medicinal_purposes"
    t.string   "reproduction"
    t.string   "seasonality"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.integer  "universe_id"
    t.string   "notes"
    t.string   "private_notes"
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "floras", ["deleted_at"], name: "index_floras_on_deleted_at"
  add_index "floras", ["universe_id"], name: "index_floras_on_universe_id"
  add_index "floras", ["user_id"], name: "index_floras_on_user_id"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "group_allyships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "ally_id"
  end

  create_table "group_clientships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "client_id"
  end

  create_table "group_enemyships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "enemy_id"
  end

  create_table "group_equipmentships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "equipment_id"
  end

  create_table "group_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "leader_id"
  end

  create_table "group_locationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "location_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "member_id"
  end

  create_table "group_rivalships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "rival_id"
  end

  create_table "group_supplierships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "supplier_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "organization_structure"
    t.string   "motivation"
    t.string   "goal"
    t.string   "obstacles"
    t.string   "risks"
    t.string   "inventory"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "groups", ["deleted_at"], name: "index_groups_on_deleted_at"

  create_table "headquarterships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "headquarter_id"
  end

  create_table "image_uploads", force: :cascade do |t|
    t.string   "privacy"
    t.integer  "user_id"
    t.string   "content_type"
    t.integer  "content_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "src_file_name"
    t.string   "src_content_type"
    t.integer  "src_file_size"
    t.datetime "src_updated_at"
  end

  add_index "image_uploads", ["user_id"], name: "index_image_uploads_on_user_id"

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
    t.datetime "deleted_at"
  end

  add_index "items", ["deleted_at"], name: "index_items_on_deleted_at"

  create_table "key_itemships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "key_item_id"
  end

  create_table "landmark_countries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "landmark_id"
    t.integer  "country_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "landmark_countries", ["country_id"], name: "index_landmark_countries_on_country_id"
  add_index "landmark_countries", ["landmark_id"], name: "index_landmark_countries_on_landmark_id"
  add_index "landmark_countries", ["user_id"], name: "index_landmark_countries_on_user_id"

  create_table "landmark_creatures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "landmark_id"
    t.integer  "creature_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "landmark_creatures", ["creature_id"], name: "index_landmark_creatures_on_creature_id"
  add_index "landmark_creatures", ["landmark_id"], name: "index_landmark_creatures_on_landmark_id"
  add_index "landmark_creatures", ["user_id"], name: "index_landmark_creatures_on_user_id"

  create_table "landmark_floras", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "landmark_id"
    t.integer  "flora_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "landmark_floras", ["flora_id"], name: "index_landmark_floras_on_flora_id"
  add_index "landmark_floras", ["landmark_id"], name: "index_landmark_floras_on_landmark_id"
  add_index "landmark_floras", ["user_id"], name: "index_landmark_floras_on_user_id"

  create_table "landmark_nearby_towns", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "landmark_id"
    t.integer  "nearby_town_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "landmark_nearby_towns", ["landmark_id"], name: "index_landmark_nearby_towns_on_landmark_id"
  add_index "landmark_nearby_towns", ["user_id"], name: "index_landmark_nearby_towns_on_user_id"

  create_table "landmarks", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.integer  "universe_id"
    t.string   "size"
    t.string   "materials"
    t.string   "colors"
    t.string   "creation_story"
    t.string   "established_year"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.string   "privacy"
    t.integer  "user_id"
  end

  add_index "landmarks", ["universe_id"], name: "index_landmarks_on_universe_id"
  add_index "landmarks", ["user_id"], name: "index_landmarks_on_user_id"

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.string   "other_names"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "history"
    t.string   "typology"
    t.string   "dialectical_information"
    t.string   "register"
    t.string   "phonology"
    t.string   "grammar"
    t.string   "numbers"
    t.string   "quantifiers"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "languages", ["deleted_at"], name: "index_languages_on_deleted_at"

  create_table "largest_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "largest_city_id"
  end

  create_table "lingualisms", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "spoken_language_id"
  end

  create_table "location_languageships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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
    t.datetime "deleted_at"
  end

  add_index "locations", ["deleted_at"], name: "index_locations_on_deleted_at"

  create_table "magic_deityships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "magic_id"
    t.integer "deity_id"
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
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "magics", ["deleted_at"], name: "index_magics_on_deleted_at"

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

  create_table "officeships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "office_id"
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
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "races", ["deleted_at"], name: "index_races_on_deleted_at"

  create_table "raceships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "race_id"
  end

  create_table "raffle_entries", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "raffle_entries", ["user_id"], name: "index_raffle_entries_on_user_id"

  create_table "referral_codes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "referral_codes", ["user_id"], name: "index_referral_codes_on_user_id"

  create_table "referrals", force: :cascade do |t|
    t.integer  "referrer_id"
    t.integer  "referred_id"
    t.integer  "associated_code_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
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
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "religions", ["deleted_at"], name: "index_religions_on_deleted_at"

  create_table "religious_figureships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "user_id"
    t.integer "notable_figure_id"
  end

  create_table "religious_locationships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "practicing_location_id"
    t.integer "user_id"
  end

  create_table "religious_raceships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "race_id"
    t.integer "user_id"
  end

  create_table "scene_characterships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "scene_id"
    t.integer "scene_character_id"
  end

  create_table "scene_itemships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "scene_id"
    t.integer "scene_item_id"
  end

  create_table "scene_locationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "scene_id"
    t.integer "scene_location_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.integer  "scene_number"
    t.string   "name"
    t.string   "summary"
    t.integer  "universe_id"
    t.integer  "user_id"
    t.string   "cause"
    t.string   "description"
    t.string   "results"
    t.string   "prose"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "privacy"
    t.datetime "deleted_at"
  end

  add_index "scenes", ["deleted_at"], name: "index_scenes_on_deleted_at"

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

  create_table "sistergroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "sistergroup_id"
  end

  create_table "subgroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "subgroup_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "billing_plan_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "subscriptions", ["billing_plan_id"], name: "index_subscriptions_on_billing_plan_id"
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "supergroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "supergroup_id"
  end

  create_table "thredded_categories", force: :cascade do |t|
    t.integer  "messageboard_id",             null: false
    t.string   "name",            limit: 191, null: false
    t.string   "description",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "slug",            limit: 191, null: false
  end

  add_index "thredded_categories", ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
  add_index "thredded_categories", ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
  add_index "thredded_categories", ["name"], name: "thredded_categories_name_ci"

  create_table "thredded_messageboard_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "position",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_messageboard_notifications_for_followed_topics", force: :cascade do |t|
    t.integer "user_id",                                   null: false
    t.integer "messageboard_id",                           null: false
    t.string  "notifier_key",    limit: 90,                null: false
    t.boolean "enabled",                    default: true, null: false
  end

  add_index "thredded_messageboard_notifications_for_followed_topics", ["user_id", "messageboard_id", "notifier_key"], name: "thredded_messageboard_notifications_for_followed_topics_unique", unique: true

  create_table "thredded_messageboard_users", force: :cascade do |t|
    t.integer  "thredded_user_detail_id",  null: false
    t.integer  "thredded_messageboard_id", null: false
    t.datetime "last_seen_at",             null: false
  end

  add_index "thredded_messageboard_users", ["thredded_messageboard_id", "last_seen_at"], name: "index_thredded_messageboard_users_for_recently_active"
  add_index "thredded_messageboard_users", ["thredded_messageboard_id", "thredded_user_detail_id"], name: "index_thredded_messageboard_users_primary"

  create_table "thredded_messageboards", force: :cascade do |t|
    t.string   "name",                  limit: 191,             null: false
    t.string   "slug",                  limit: 191
    t.text     "description"
    t.integer  "topics_count",                      default: 0
    t.integer  "posts_count",                       default: 0
    t.integer  "position",                                      null: false
    t.integer  "last_topic_id"
    t.integer  "messageboard_group_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "thredded_messageboards", ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
  add_index "thredded_messageboards", ["slug"], name: "index_thredded_messageboards_on_slug"

  create_table "thredded_notifications_for_followed_topics", force: :cascade do |t|
    t.integer "user_id",                                null: false
    t.string  "notifier_key", limit: 90,                null: false
    t.boolean "enabled",                 default: true, null: false
  end

  add_index "thredded_notifications_for_followed_topics", ["user_id", "notifier_key"], name: "thredded_notifications_for_followed_topics_unique", unique: true

  create_table "thredded_notifications_for_private_topics", force: :cascade do |t|
    t.integer "user_id",                                null: false
    t.string  "notifier_key", limit: 90,                null: false
    t.boolean "enabled",                 default: true, null: false
  end

  add_index "thredded_notifications_for_private_topics", ["user_id", "notifier_key"], name: "thredded_notifications_for_private_topics_unique", unique: true

  create_table "thredded_post_moderation_records", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "messageboard_id"
    t.text     "post_content",              limit: 65535
    t.integer  "post_user_id"
    t.text     "post_user_name"
    t.integer  "moderator_id"
    t.integer  "moderation_state",                        null: false
    t.integer  "previous_moderation_state",               null: false
    t.datetime "created_at",                              null: false
  end

  add_index "thredded_post_moderation_records", ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display"

  create_table "thredded_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content",          limit: 65535
    t.string   "ip",               limit: 255
    t.string   "source",           limit: 255,   default: "web"
    t.integer  "postable_id",                                    null: false
    t.integer  "messageboard_id",                                null: false
    t.integer  "moderation_state",                               null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "thredded_posts", ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
  add_index "thredded_posts", ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
  add_index "thredded_posts", ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
  add_index "thredded_posts", ["user_id"], name: "index_thredded_posts_on_user_id"

  create_table "thredded_private_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content",     limit: 65535
    t.integer  "postable_id",               null: false
    t.string   "ip",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "thredded_private_topics", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "last_user_id"
    t.string   "title",        limit: 255,             null: false
    t.string   "slug",         limit: 191,             null: false
    t.integer  "posts_count",              default: 0
    t.string   "hash_id",      limit: 191,             null: false
    t.datetime "last_post_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "thredded_private_topics", ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
  add_index "thredded_private_topics", ["slug"], name: "index_thredded_private_topics_on_slug"

  create_table "thredded_private_users", force: :cascade do |t|
    t.integer  "private_topic_id"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "thredded_private_users", ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
  add_index "thredded_private_users", ["user_id"], name: "index_thredded_private_users_on_user_id"

  create_table "thredded_topic_categories", force: :cascade do |t|
    t.integer "topic_id",    null: false
    t.integer "category_id", null: false
  end

  add_index "thredded_topic_categories", ["category_id"], name: "index_thredded_topic_categories_on_category_id"
  add_index "thredded_topic_categories", ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"

  create_table "thredded_topics", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "last_user_id"
    t.string   "title",            limit: 255,                 null: false
    t.string   "slug",             limit: 191,                 null: false
    t.integer  "messageboard_id",                              null: false
    t.integer  "posts_count",                  default: 0,     null: false
    t.boolean  "sticky",                       default: false, null: false
    t.boolean  "locked",                       default: false, null: false
    t.string   "hash_id",          limit: 191,                 null: false
    t.string   "type",             limit: 191
    t.integer  "moderation_state",                             null: false
    t.datetime "last_post_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "thredded_topics", ["hash_id"], name: "index_thredded_topics_on_hash_id"
  add_index "thredded_topics", ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
  add_index "thredded_topics", ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display"
  add_index "thredded_topics", ["slug"], name: "index_thredded_topics_on_slug", unique: true
  add_index "thredded_topics", ["user_id"], name: "index_thredded_topics_on_user_id"

  create_table "thredded_user_details", force: :cascade do |t|
    t.integer  "user_id",                                 null: false
    t.datetime "latest_activity_at"
    t.integer  "posts_count",                 default: 0
    t.integer  "topics_count",                default: 0
    t.datetime "last_seen_at"
    t.integer  "moderation_state",            default: 0, null: false
    t.datetime "moderation_state_changed_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "thredded_user_details", ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
  add_index "thredded_user_details", ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations"
  add_index "thredded_user_details", ["user_id"], name: "index_thredded_user_details_on_user_id"

  create_table "thredded_user_messageboard_preferences", force: :cascade do |t|
    t.integer  "user_id",                                  null: false
    t.integer  "messageboard_id",                          null: false
    t.boolean  "follow_topics_on_mention", default: true,  null: false
    t.boolean  "auto_follow_topics",       default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "thredded_user_messageboard_preferences", ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true

  create_table "thredded_user_post_notifications", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "post_id",     null: false
    t.datetime "notified_at", null: false
  end

  add_index "thredded_user_post_notifications", ["post_id"], name: "index_thredded_user_post_notifications_on_post_id"
  add_index "thredded_user_post_notifications", ["user_id", "post_id"], name: "index_thredded_user_post_notifications_on_user_id_and_post_id", unique: true

  create_table "thredded_user_preferences", force: :cascade do |t|
    t.integer  "user_id",                                  null: false
    t.boolean  "follow_topics_on_mention", default: true,  null: false
    t.boolean  "auto_follow_topics",       default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "thredded_user_preferences", ["user_id"], name: "index_thredded_user_preferences_on_user_id"

  create_table "thredded_user_private_topic_read_states", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "postable_id",             null: false
    t.integer  "page",        default: 1, null: false
    t.datetime "read_at",                 null: false
  end

  add_index "thredded_user_private_topic_read_states", ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true

  create_table "thredded_user_topic_follows", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.integer  "topic_id",             null: false
    t.datetime "created_at",           null: false
    t.integer  "reason",     limit: 1
  end

  add_index "thredded_user_topic_follows", ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true

  create_table "thredded_user_topic_read_states", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "postable_id",             null: false
    t.integer  "page",        default: 1, null: false
    t.datetime "read_at",                 null: false
  end

  add_index "thredded_user_topic_read_states", ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true

  create_table "town_citizens", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "citizen_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "town_citizens", ["town_id"], name: "index_town_citizens_on_town_id"
  add_index "town_citizens", ["user_id"], name: "index_town_citizens_on_user_id"

  create_table "town_countries", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "town_countries", ["country_id"], name: "index_town_countries_on_country_id"
  add_index "town_countries", ["town_id"], name: "index_town_countries_on_town_id"
  add_index "town_countries", ["user_id"], name: "index_town_countries_on_user_id"

  create_table "town_creatures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "creature_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "town_creatures", ["creature_id"], name: "index_town_creatures_on_creature_id"
  add_index "town_creatures", ["town_id"], name: "index_town_creatures_on_town_id"
  add_index "town_creatures", ["user_id"], name: "index_town_creatures_on_user_id"

  create_table "town_floras", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "town_floras", ["flora_id"], name: "index_town_floras_on_flora_id"
  add_index "town_floras", ["town_id"], name: "index_town_floras_on_town_id"
  add_index "town_floras", ["user_id"], name: "index_town_floras_on_user_id"

  create_table "town_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "town_groups", ["group_id"], name: "index_town_groups_on_group_id"
  add_index "town_groups", ["town_id"], name: "index_town_groups_on_town_id"
  add_index "town_groups", ["user_id"], name: "index_town_groups_on_user_id"

  create_table "town_languages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "town_languages", ["language_id"], name: "index_town_languages_on_language_id"
  add_index "town_languages", ["town_id"], name: "index_town_languages_on_town_id"
  add_index "town_languages", ["user_id"], name: "index_town_languages_on_user_id"

  create_table "town_nearby_landmarks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "town_id"
    t.integer  "nearby_landmark_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "town_nearby_landmarks", ["town_id"], name: "index_town_nearby_landmarks_on_town_id"
  add_index "town_nearby_landmarks", ["user_id"], name: "index_town_nearby_landmarks_on_user_id"

  create_table "towns", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "other_names"
    t.string   "laws"
    t.string   "sports"
    t.string   "politics"
    t.string   "founding_story"
    t.string   "established_year"
    t.string   "notes"
    t.string   "private_notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "universe_id"
    t.datetime "deleted_at"
    t.string   "privacy"
    t.integer  "user_id"
  end

  add_index "towns", ["universe_id"], name: "index_towns_on_universe_id"
  add_index "towns", ["user_id"], name: "index_towns_on_user_id"

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
    t.string   "genre"
    t.datetime "deleted_at"
  end

  add_index "universes", ["deleted_at"], name: "index_universes_on_deleted_at"

  create_table "user_content_type_activators", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "content_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "user_content_type_activators", ["user_id"], name: "index_user_content_type_activators_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                                    null: false
    t.string   "old_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "plan_type"
    t.string   "stripe_customer_id"
    t.boolean  "email_updates",            default: true
    t.integer  "selected_billing_plan_id"
    t.integer  "upload_bandwidth_kb",      default: 50000
    t.string   "secure_code"
    t.boolean  "fluid_preference"
    t.string   "username"
    t.boolean  "forum_administrator",      default: false, null: false
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "votables", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "icon"
    t.string   "link"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "votable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "votes", ["user_id"], name: "index_votes_on_user_id"
  add_index "votes", ["votable_id"], name: "index_votes_on_votable_id"

  create_table "wildlifeships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "creature_id"
    t.integer "habitat_id"
  end

end
