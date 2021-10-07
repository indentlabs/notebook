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

ActiveRecord::Schema.define(version: 2021_10_07_215520) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.integer "user_id"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "api_requests", force: :cascade do |t|
    t.integer "application_integration_id"
    t.integer "integration_authorization_id"
    t.string "result"
    t.integer "updates_used", default: 0
    t.string "ip_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_integration_id"], name: "index_api_requests_on_application_integration_id"
    t.index ["integration_authorization_id"], name: "index_api_requests_on_integration_authorization_id"
  end

  create_table "application_integrations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "description"
    t.string "organization_name"
    t.string "organization_url"
    t.string "website_url"
    t.string "privacy_policy_url"
    t.string "token"
    t.datetime "last_used_at"
    t.string "authorization_callback_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "event_ping_url"
    t.string "application_token"
    t.index ["user_id"], name: "index_application_integrations_on_user_id"
  end

  create_table "archenemyships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "archenemy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artifactships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "artifact_id"
    t.integer "user_id"
  end

  create_table "attribute_categories", force: :cascade do |t|
    t.integer "user_id"
    t.string "entity_type"
    t.string "name", null: false
    t.string "label", null: false
    t.string "icon"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "hidden", default: false
    t.datetime "deleted_at"
    t.integer "position"
    t.index ["entity_type", "name", "user_id"], name: "index_attribute_categories_on_entity_type_and_name_and_user_id"
    t.index ["entity_type"], name: "index_attribute_categories_on_entity_type"
    t.index ["name"], name: "index_attribute_categories_on_name"
    t.index ["user_id"], name: "index_attribute_categories_on_user_id"
  end

  create_table "attribute_category_suggestions", force: :cascade do |t|
    t.string "entity_type"
    t.string "suggestion"
    t.integer "weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attribute_field_suggestions", force: :cascade do |t|
    t.string "entity_type"
    t.string "category_label"
    t.string "suggestion"
    t.integer "weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attribute_fields", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attribute_category_id", null: false
    t.string "name", null: false
    t.string "label", null: false
    t.string "field_type", null: false
    t.text "description"
    t.string "privacy", default: "public", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "hidden", default: false
    t.datetime "deleted_at"
    t.string "old_column_source"
    t.integer "position"
    t.json "field_options"
    t.boolean "migrated_from_legacy", default: false
    t.index ["attribute_category_id", "deleted_at"], name: "index_attribute_fields_on_attribute_category_id_and_deleted_at"
    t.index ["attribute_category_id", "label", "old_column_source", "field_type"], name: "attribute_fields_aci_label_ocs_ft"
    t.index ["attribute_category_id", "label", "old_column_source", "user_id", "field_type"], name: "attribute_fields_aci_label_ocs_ui_ft"
    t.index ["attribute_category_id", "old_column_source", "user_id", "field_type"], name: "attribute_fields_aci_ocs_ui_ft"
    t.index ["deleted_at", "attribute_category_id"], name: "deleted_at__attribute_category_id"
    t.index ["deleted_at", "name"], name: "index_attribute_fields_on_deleted_at_and_name"
    t.index ["deleted_at", "position"], name: "index_attribute_fields_on_deleted_at_and_position"
    t.index ["deleted_at", "user_id", "attribute_category_id", "label", "hidden"], name: "attribute_fields_da_ui_aci_l_h"
    t.index ["user_id", "attribute_category_id", "field_type", "deleted_at"], name: "special_field_type_index"
    t.index ["user_id", "attribute_category_id", "label", "hidden", "deleted_at"], name: "field_lookup_by_label_index"
    t.index ["user_id", "attribute_category_id", "label", "old_column_source", "field_type", "deleted_at"], name: "temporary_migration_lookup_with_deleted_index"
    t.index ["user_id", "attribute_category_id", "label", "old_column_source", "field_type"], name: "temporary_migration_lookup_index"
    t.index ["user_id", "attribute_category_id"], name: "index_attribute_fields_on_user_id_and_attribute_category_id"
    t.index ["user_id", "field_type"], name: "index_attribute_fields_on_user_id_and_field_type"
    t.index ["user_id", "name"], name: "index_attribute_fields_on_user_id_and_name"
    t.index ["user_id", "old_column_source"], name: "index_attribute_fields_on_user_id_and_old_column_source"
    t.index ["user_id"], name: "index_attribute_fields_on_user_id"
  end

  create_table "attributes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attribute_field_id"
    t.string "entity_type", null: false
    t.integer "entity_id", null: false
    t.text "value"
    t.string "privacy", default: "private", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "word_count_cache"
    t.index ["attribute_field_id", "deleted_at", "entity_id", "entity_type"], name: "attributes_afi_deleted_at_entity_id_entity_type"
    t.index ["attribute_field_id", "deleted_at"], name: "index_attributes_on_attribute_field_id_and_deleted_at"
    t.index ["attribute_field_id", "user_id", "entity_type", "entity_id", "deleted_at"], name: "attributes_afi_ui_et_ei_da"
    t.index ["deleted_at", "attribute_field_id", "entity_type", "entity_id"], name: "deleted_at__attribute_field_id__entity_type_and_id"
    t.index ["deleted_at", "user_id", "attribute_field_id", "entity_type", "entity_id", "id"], name: "all_the_export_fields_with_sort"
    t.index ["deleted_at", "user_id", "attribute_field_id", "entity_type", "entity_id"], name: "all_the_export_fields"
    t.index ["entity_type", "entity_id"], name: "index_attributes_on_entity_type_and_entity_id"
    t.index ["user_id", "attribute_field_id"], name: "index_attributes_on_user_id_and_attribute_field_id"
    t.index ["user_id", "deleted_at"], name: "index_attributes_on_user_id_and_deleted_at"
    t.index ["user_id", "entity_type", "entity_id"], name: "index_attributes_on_user_id_and_entity_type_and_entity_id"
    t.index ["user_id"], name: "index_attributes_on_user_id"
  end

  create_table "best_friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "best_friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_plans", force: :cascade do |t|
    t.string "name"
    t.string "stripe_plan_id"
    t.integer "monthly_cents"
    t.boolean "available"
    t.boolean "allows_core_content"
    t.boolean "allows_extended_content"
    t.boolean "allows_collective_content"
    t.boolean "allows_collaboration"
    t.integer "universe_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bonus_bandwidth_kb", default: 0
  end

  create_table "birthings", force: :cascade do |t|
    t.integer "character_id"
    t.integer "birthplace_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_countries", force: :cascade do |t|
    t.integer "building_id"
    t.integer "country_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "building_landmarks", force: :cascade do |t|
    t.integer "building_id"
    t.integer "landmark_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "building_locations", force: :cascade do |t|
    t.integer "building_id"
    t.integer "location_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "building_nearby_buildings", force: :cascade do |t|
    t.integer "building_id"
    t.integer "nearby_building_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "building_schools", force: :cascade do |t|
    t.integer "building_id"
    t.integer "district_school_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "building_towns", force: :cascade do |t|
    t.integer "building_id"
    t.integer "town_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Building"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_buildings_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_buildings_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_buildings_on_user_id"
  end

  create_table "capital_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "capital_city_id"
  end

  create_table "character_birthtowns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "birthtown_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_birthtowns_on_character_id"
    t.index ["user_id"], name: "index_character_birthtowns_on_user_id"
  end

  create_table "character_companions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "companion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_companions_on_character_id"
    t.index ["user_id"], name: "index_character_companions_on_user_id"
  end

  create_table "character_enemies", force: :cascade do |t|
    t.integer "character_id"
    t.integer "enemy_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_enemies_on_character_id"
    t.index ["user_id"], name: "index_character_enemies_on_user_id"
  end

  create_table "character_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_floras_on_character_id"
    t.index ["flora_id"], name: "index_character_floras_on_flora_id"
    t.index ["user_id"], name: "index_character_floras_on_user_id"
  end

  create_table "character_friends", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_friends_on_character_id"
    t.index ["user_id"], name: "index_character_friends_on_user_id"
  end

  create_table "character_items", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_items_on_character_id"
    t.index ["item_id"], name: "index_character_items_on_item_id"
    t.index ["user_id"], name: "index_character_items_on_user_id"
  end

  create_table "character_love_interests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "love_interest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_love_interests_on_character_id"
    t.index ["user_id"], name: "index_character_love_interests_on_user_id"
  end

  create_table "character_magics", force: :cascade do |t|
    t.integer "character_id"
    t.integer "magic_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_magics_on_character_id"
    t.index ["magic_id"], name: "index_character_magics_on_magic_id"
    t.index ["user_id"], name: "index_character_magics_on_user_id"
  end

  create_table "character_technologies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "technology_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_technologies_on_character_id"
    t.index ["technology_id"], name: "index_character_technologies_on_technology_id"
    t.index ["user_id"], name: "index_character_technologies_on_user_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name", null: false
    t.string "role"
    t.string "gender"
    t.string "age"
    t.string "height"
    t.string "weight"
    t.string "haircolor"
    t.string "hairstyle"
    t.string "facialhair"
    t.string "eyecolor"
    t.string "race"
    t.string "skintone"
    t.string "bodytype"
    t.string "identmarks"
    t.text "religion"
    t.text "politics"
    t.text "prejudices"
    t.text "occupation"
    t.text "pets"
    t.text "mannerisms"
    t.text "birthday"
    t.text "birthplace"
    t.text "education"
    t.text "background"
    t.string "fave_color"
    t.string "fave_food"
    t.string "fave_possession"
    t.string "fave_weapon"
    t.string "fave_animal"
    t.text "notes"
    t.text "private_notes"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "privacy"
    t.string "archetype"
    t.string "aliases"
    t.string "motivations"
    t.string "flaws"
    t.string "talents"
    t.string "hobbies"
    t.string "personality_type"
    t.datetime "deleted_at"
    t.string "page_type", default: "Character"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_characters_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_characters_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_characters_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_characters_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_characters_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_characters_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_characters_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "childrenships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "child_id"
  end

  create_table "conditions", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Condition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_conditions_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_conditions_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_conditions_on_user_id"
  end

  create_table "content_change_events", force: :cascade do |t|
    t.integer "user_id"
    t.text "changed_fields"
    t.integer "content_id"
    t.string "content_type"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id", "content_type"], name: "index_content_change_events_on_content_id_and_content_type"
    t.index ["user_id"], name: "index_content_change_events_on_user_id"
  end

  create_table "content_page_share_followings", force: :cascade do |t|
    t.integer "content_page_share_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_page_share_id"], name: "index_content_page_share_followings_on_content_page_share_id"
    t.index ["user_id"], name: "index_content_page_share_followings_on_user_id"
  end

  create_table "content_page_share_reports", force: :cascade do |t|
    t.integer "content_page_share_id", null: false
    t.integer "user_id", null: false
    t.datetime "approved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_page_share_id"], name: "index_content_page_share_reports_on_content_page_share_id"
    t.index ["user_id"], name: "index_content_page_share_reports_on_user_id"
  end

  create_table "content_page_shares", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "content_page_type"
    t.integer "content_page_id"
    t.datetime "shared_at"
    t.string "privacy"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.string "secondary_content_page_type"
    t.integer "secondary_content_page_id"
    t.index ["content_page_type", "content_page_id"], name: "cps_index"
    t.index ["secondary_content_page_type", "secondary_content_page_id"], name: "index_secondary_content_page_share"
    t.index ["user_id"], name: "index_content_page_shares_on_user_id"
  end

  create_table "content_pages", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["universe_id"], name: "index_content_pages_on_universe_id"
    t.index ["user_id"], name: "index_content_pages_on_user_id"
  end

  create_table "continent_countries", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "country_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_countries_on_continent_id"
    t.index ["country_id"], name: "index_continent_countries_on_country_id"
    t.index ["user_id"], name: "index_continent_countries_on_user_id"
  end

  create_table "continent_creatures", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "creature_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_creatures_on_continent_id"
    t.index ["creature_id"], name: "index_continent_creatures_on_creature_id"
    t.index ["user_id"], name: "index_continent_creatures_on_user_id"
  end

  create_table "continent_floras", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "flora_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_floras_on_continent_id"
    t.index ["flora_id"], name: "index_continent_floras_on_flora_id"
    t.index ["user_id"], name: "index_continent_floras_on_user_id"
  end

  create_table "continent_governments", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "government_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_governments_on_continent_id"
    t.index ["government_id"], name: "index_continent_governments_on_government_id"
    t.index ["user_id"], name: "index_continent_governments_on_user_id"
  end

  create_table "continent_landmarks", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "landmark_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.index ["continent_id"], name: "index_continent_landmarks_on_continent_id"
    t.index ["landmark_id"], name: "index_continent_landmarks_on_landmark_id"
    t.index ["user_id"], name: "index_continent_landmarks_on_user_id"
  end

  create_table "continent_languages", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "language_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_languages_on_continent_id"
    t.index ["language_id"], name: "index_continent_languages_on_language_id"
    t.index ["user_id"], name: "index_continent_languages_on_user_id"
  end

  create_table "continent_popular_foods", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "popular_food_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_popular_foods_on_continent_id"
    t.index ["user_id"], name: "index_continent_popular_foods_on_user_id"
  end

  create_table "continent_traditions", force: :cascade do |t|
    t.integer "continent_id", null: false
    t.integer "tradition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_continent_traditions_on_continent_id"
    t.index ["tradition_id"], name: "index_continent_traditions_on_tradition_id"
    t.index ["user_id"], name: "index_continent_traditions_on_user_id"
  end

  create_table "continents", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Continent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id", "universe_id"], name: "index_continents_on_deleted_at_and_id_and_universe_id"
    t.index ["deleted_at", "id", "user_id"], name: "index_continents_on_deleted_at_and_id_and_user_id"
    t.index ["deleted_at", "id"], name: "index_continents_on_deleted_at_and_id"
    t.index ["deleted_at", "user_id"], name: "index_continents_on_deleted_at_and_user_id"
    t.index ["universe_id"], name: "index_continents_on_universe_id"
    t.index ["user_id"], name: "index_continents_on_user_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.integer "universe_id"
    t.string "email"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["universe_id"], name: "index_contributors_on_universe_id"
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.integer "universe_id"
    t.string "population"
    t.string "currency"
    t.string "laws"
    t.string "sports"
    t.string "area"
    t.string "crops"
    t.string "climate"
    t.string "founding_story"
    t.string "established_year"
    t.string "notable_wars"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "privacy"
    t.integer "user_id"
    t.string "page_type", default: "Country"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_countries_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_countries_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_countries_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_countries_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_countries_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_countries_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_countries_on_user_id"
  end

  create_table "country_bordering_countries", force: :cascade do |t|
    t.integer "country_id", null: false
    t.integer "bordering_country_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_country_bordering_countries_on_country_id"
    t.index ["user_id"], name: "index_country_bordering_countries_on_user_id"
  end

  create_table "country_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_creatures_on_country_id"
    t.index ["creature_id"], name: "index_country_creatures_on_creature_id"
    t.index ["user_id"], name: "index_country_creatures_on_user_id"
  end

  create_table "country_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_floras_on_country_id"
    t.index ["flora_id"], name: "index_country_floras_on_flora_id"
    t.index ["user_id"], name: "index_country_floras_on_user_id"
  end

  create_table "country_governments", force: :cascade do |t|
    t.integer "country_id"
    t.integer "government_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_governments_on_country_id"
    t.index ["government_id"], name: "index_country_governments_on_government_id"
    t.index ["user_id"], name: "index_country_governments_on_user_id"
  end

  create_table "country_landmarks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "landmark_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_landmarks_on_country_id"
    t.index ["landmark_id"], name: "index_country_landmarks_on_landmark_id"
    t.index ["user_id"], name: "index_country_landmarks_on_user_id"
  end

  create_table "country_languages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_languages_on_country_id"
    t.index ["language_id"], name: "index_country_languages_on_language_id"
    t.index ["user_id"], name: "index_country_languages_on_user_id"
  end

  create_table "country_locations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_locations_on_country_id"
    t.index ["location_id"], name: "index_country_locations_on_location_id"
    t.index ["user_id"], name: "index_country_locations_on_user_id"
  end

  create_table "country_religions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "religion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_religions_on_country_id"
    t.index ["religion_id"], name: "index_country_religions_on_religion_id"
    t.index ["user_id"], name: "index_country_religions_on_user_id"
  end

  create_table "country_towns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.integer "town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_country_towns_on_country_id"
    t.index ["town_id"], name: "index_country_towns_on_town_id"
    t.index ["user_id"], name: "index_country_towns_on_user_id"
  end

  create_table "creature_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "creature_id"
    t.integer "related_creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "creatures", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "type_of"
    t.string "other_names"
    t.integer "universe_id"
    t.string "color"
    t.string "shape"
    t.string "size"
    t.string "notable_features"
    t.string "materials"
    t.string "preferred_habitat"
    t.string "sounds"
    t.string "strengths"
    t.string "weaknesses"
    t.string "spoils"
    t.string "aggressiveness"
    t.string "attack_method"
    t.string "defense_method"
    t.string "maximum_speed"
    t.string "food_sources"
    t.string "migratory_patterns"
    t.string "reproduction"
    t.string "herd_patterns"
    t.string "similar_animals"
    t.string "symbolisms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "notes"
    t.string "private_notes"
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "phylum"
    t.string "class_string"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "species"
    t.string "page_type", default: "Creature"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_creatures_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_creatures_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_creatures_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_creatures_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_creatures_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_creatures_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_creatures_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_creatures_on_user_id"
  end

  create_table "current_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "current_owner_id"
  end

  create_table "deities", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.string "physical_description"
    t.string "height"
    t.string "weight"
    t.string "symbols"
    t.string "elements"
    t.string "strengths"
    t.string "weaknesses"
    t.string "prayers"
    t.string "rituals"
    t.string "human_interaction"
    t.string "notable_events"
    t.string "family_history"
    t.string "life_story"
    t.string "notes"
    t.string "private_notes"
    t.string "privacy"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page_type", default: "Deity"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_deities_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_deities_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_deities_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_deities_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_deities_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_deities_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_deities_on_user_id"
  end

  create_table "deity_abilities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "ability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_abilities_on_deity_id"
    t.index ["user_id"], name: "index_deity_abilities_on_user_id"
  end

  create_table "deity_character_children", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "character_child_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_character_children_on_deity_id"
    t.index ["user_id"], name: "index_deity_character_children_on_user_id"
  end

  create_table "deity_character_parents", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "character_parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_character_parents_on_deity_id"
    t.index ["user_id"], name: "index_deity_character_parents_on_user_id"
  end

  create_table "deity_character_partners", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "character_partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_character_partners_on_deity_id"
    t.index ["user_id"], name: "index_deity_character_partners_on_user_id"
  end

  create_table "deity_character_siblings", force: :cascade do |t|
    t.integer "deity_id"
    t.integer "character_sibling_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_character_siblings_on_deity_id"
    t.index ["user_id"], name: "index_deity_character_siblings_on_user_id"
  end

  create_table "deity_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_deity_creatures_on_creature_id"
    t.index ["deity_id"], name: "index_deity_creatures_on_deity_id"
    t.index ["user_id"], name: "index_deity_creatures_on_user_id"
  end

  create_table "deity_deity_children", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "deity_child_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_deity_children_on_deity_id"
    t.index ["user_id"], name: "index_deity_deity_children_on_user_id"
  end

  create_table "deity_deity_parents", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "deity_parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_deity_parents_on_deity_id"
    t.index ["user_id"], name: "index_deity_deity_parents_on_user_id"
  end

  create_table "deity_deity_partners", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "deity_partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_deity_partners_on_deity_id"
    t.index ["user_id"], name: "index_deity_deity_partners_on_user_id"
  end

  create_table "deity_deity_siblings", force: :cascade do |t|
    t.integer "deity_id"
    t.integer "deity_sibling_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_deity_siblings_on_deity_id"
    t.index ["user_id"], name: "index_deity_deity_siblings_on_user_id"
  end

  create_table "deity_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_floras_on_deity_id"
    t.index ["flora_id"], name: "index_deity_floras_on_flora_id"
    t.index ["user_id"], name: "index_deity_floras_on_user_id"
  end

  create_table "deity_races", force: :cascade do |t|
    t.integer "deity_id"
    t.integer "race_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_races_on_deity_id"
    t.index ["race_id"], name: "index_deity_races_on_race_id"
    t.index ["user_id"], name: "index_deity_races_on_user_id"
  end

  create_table "deity_related_landmarks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "related_landmark_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_related_landmarks_on_deity_id"
    t.index ["user_id"], name: "index_deity_related_landmarks_on_user_id"
  end

  create_table "deity_related_towns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "related_town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_related_towns_on_deity_id"
    t.index ["user_id"], name: "index_deity_related_towns_on_user_id"
  end

  create_table "deity_relics", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "relic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_relics_on_deity_id"
    t.index ["user_id"], name: "index_deity_relics_on_user_id"
  end

  create_table "deity_religions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deity_id"
    t.integer "religion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_deity_religions_on_deity_id"
    t.index ["religion_id"], name: "index_deity_religions_on_religion_id"
    t.index ["user_id"], name: "index_deity_religions_on_user_id"
  end

  create_table "deityships", force: :cascade do |t|
    t.integer "religion_id"
    t.integer "deity_id"
    t.integer "user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "document_analyses", force: :cascade do |t|
    t.integer "document_id"
    t.integer "word_count"
    t.integer "page_count"
    t.integer "paragraph_count"
    t.integer "character_count"
    t.integer "sentence_count"
    t.integer "readability_score"
    t.float "combined_average_reading_level"
    t.integer "flesch_kincaid_grade_level"
    t.integer "flesch_kincaid_age_minimum"
    t.float "flesch_kincaid_reading_ease"
    t.float "forcast_grade_level"
    t.float "coleman_liau_index"
    t.float "automated_readability_index"
    t.float "gunning_fog_index"
    t.float "smog_grade"
    t.integer "adjective_count"
    t.integer "noun_count"
    t.integer "verb_count"
    t.integer "pronoun_count"
    t.integer "preposition_count"
    t.integer "conjunction_count"
    t.integer "adverb_count"
    t.integer "determiner_count"
    t.json "n_syllable_words"
    t.integer "words_used_once_count"
    t.integer "words_used_repeatedly_count"
    t.integer "simple_words_count"
    t.integer "complex_words_count"
    t.float "sentiment_score"
    t.string "sentiment_label"
    t.string "language"
    t.float "sadness_score"
    t.float "joy_score"
    t.float "fear_score"
    t.float "disgust_score"
    t.float "anger_score"
    t.json "words_per_sentence"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "progress", default: 0
    t.integer "interrogative_count"
    t.integer "proper_noun_count"
    t.datetime "queued_at"
    t.float "linsear_write_grade"
    t.float "dale_chall_grade"
    t.integer "unique_complex_words_count"
    t.integer "unique_simple_words_count"
    t.boolean "hate_content_flag", default: false
    t.string "hate_trigger_words"
    t.boolean "profanity_content_flag", default: false
    t.string "profanity_trigger_words"
    t.boolean "sex_content_flag", default: false
    t.string "sex_trigger_words"
    t.boolean "violence_content_flag", default: false
    t.string "violence_trigger_words"
    t.boolean "adult_content_flag", default: false
    t.json "most_used_words"
    t.json "most_used_adjectives"
    t.json "most_used_nouns"
    t.json "most_used_verbs"
    t.json "most_used_adverbs"
    t.index ["document_id"], name: "index_document_analyses_on_document_id"
  end

  create_table "document_categories", force: :cascade do |t|
    t.integer "document_analysis_id"
    t.string "label"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_analysis_id"], name: "index_document_categories_on_document_analysis_id"
  end

  create_table "document_concepts", force: :cascade do |t|
    t.integer "document_analysis_id"
    t.string "text"
    t.float "relevance"
    t.string "reference_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_analysis_id"], name: "index_document_concepts_on_document_analysis_id"
  end

  create_table "document_entities", force: :cascade do |t|
    t.string "entity_type"
    t.integer "entity_id"
    t.string "text"
    t.float "relevance"
    t.integer "document_analysis_id"
    t.string "sentiment_label"
    t.float "sentiment_score"
    t.float "sadness_score"
    t.float "joy_score"
    t.float "fear_score"
    t.float "disgust_score"
    t.float "anger_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_analysis_id"], name: "index_document_entities_on_document_analysis_id"
    t.index ["entity_type", "entity_id"], name: "index_document_entities_on_entity_type_and_entity_id"
  end

  create_table "document_revisions", force: :cascade do |t|
    t.integer "document_id", null: false
    t.string "title"
    t.string "body"
    t.string "synopsis"
    t.integer "universe_id"
    t.string "notes_text"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cached_word_count"
    t.index ["document_id"], name: "index_document_revisions_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", default: "Untitled document"
    t.string "privacy", default: "private"
    t.text "synopsis"
    t.datetime "deleted_at"
    t.integer "universe_id"
    t.boolean "favorite", default: false
    t.text "notes_text"
    t.integer "folder_id"
    t.integer "cached_word_count"
    t.index ["deleted_at", "universe_id", "user_id"], name: "index_documents_on_deleted_at_and_universe_id_and_user_id"
    t.index ["deleted_at", "universe_id"], name: "index_documents_on_deleted_at_and_universe_id"
    t.index ["folder_id"], name: "index_documents_on_folder_id"
    t.index ["universe_id", "deleted_at"], name: "index_documents_on_universe_id_and_deleted_at"
    t.index ["universe_id"], name: "index_documents_on_universe_id"
    t.index ["user_id", "deleted_at"], name: "index_documents_on_user_id_and_deleted_at"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "end_of_day_analytics_reports", force: :cascade do |t|
    t.date "day"
    t.integer "user_signups"
    t.integer "new_monthly_subscriptions"
    t.integer "ended_monthly_subscriptions"
    t.integer "new_trimonthly_subscriptions"
    t.integer "ended_trimonthly_subscriptions"
    t.integer "new_annual_subscriptions"
    t.integer "ended_annual_subscriptions"
    t.integer "paid_paypal_invoices"
    t.integer "buildings_created"
    t.integer "characters_created"
    t.integer "conditions_created"
    t.integer "continents_created"
    t.integer "countries_created"
    t.integer "creatures_created"
    t.integer "deities_created"
    t.integer "floras_created"
    t.integer "foods_created"
    t.integer "governments_created"
    t.integer "groups_created"
    t.integer "items_created"
    t.integer "jobs_created"
    t.integer "landmarks_created"
    t.integer "languages_created"
    t.integer "locations_created"
    t.integer "lores_created"
    t.integer "magics_created"
    t.integer "planets_created"
    t.integer "races_created"
    t.integer "religions_created"
    t.integer "scenes_created"
    t.integer "schools_created"
    t.integer "sports_created"
    t.integer "technologies_created"
    t.integer "towns_created"
    t.integer "traditions_created"
    t.integer "universes_created"
    t.integer "vehicles_created"
    t.integer "documents_created"
    t.integer "documents_edited"
    t.integer "timelines_created"
    t.integer "stream_shares_created"
    t.integer "stream_comments"
    t.integer "collections_created"
    t.integer "collection_submissions_created"
    t.integer "thredded_threads_created"
    t.integer "thredded_replies_created"
    t.integer "thredded_private_messages_created"
    t.integer "thredded_private_replies_created"
    t.integer "document_analyses_created"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "document_revisions_created"
  end

  create_table "famous_figureships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "race_id"
    t.integer "famous_figure_id"
  end

  create_table "fatherships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "father_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flora_eaten_bies", force: :cascade do |t|
    t.integer "flora_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flora_locations", force: :cascade do |t|
    t.integer "flora_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flora_magical_effects", force: :cascade do |t|
    t.integer "flora_id"
    t.integer "magic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flora_relationships", force: :cascade do |t|
    t.integer "flora_id"
    t.integer "related_flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "floras", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "aliases"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "colorings"
    t.string "size"
    t.string "smell"
    t.string "taste"
    t.string "fruits"
    t.string "seeds"
    t.string "nuts"
    t.string "berries"
    t.string "medicinal_purposes"
    t.string "reproduction"
    t.string "seasonality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "universe_id"
    t.string "notes"
    t.string "private_notes"
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "material_uses"
    t.string "page_type", default: "Flora"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_floras_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_floras_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_floras_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_floras_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_floras_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_floras_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_floras_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_floras_on_user_id"
  end

  create_table "folders", force: :cascade do |t|
    t.string "title", default: "New Folder"
    t.string "context", default: "Document"
    t.integer "parent_folder_id"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["parent_folder_id"], name: "index_folders_on_parent_folder_id"
    t.index ["user_id", "context", "parent_folder_id"], name: "index_folders_on_user_id_and_context_and_parent_folder_id"
    t.index ["user_id", "context"], name: "index_folders_on_user_id_and_context"
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Food"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_foods_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_foods_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_foods_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "government_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_government_creatures_on_creature_id"
    t.index ["government_id"], name: "index_government_creatures_on_government_id"
    t.index ["user_id"], name: "index_government_creatures_on_user_id"
  end

  create_table "government_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_id"], name: "index_government_groups_on_government_id"
    t.index ["group_id"], name: "index_government_groups_on_group_id"
    t.index ["user_id"], name: "index_government_groups_on_user_id"
  end

  create_table "government_items", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_id"], name: "index_government_items_on_government_id"
    t.index ["item_id"], name: "index_government_items_on_item_id"
    t.index ["user_id"], name: "index_government_items_on_user_id"
  end

  create_table "government_leaders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "leader_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_id"], name: "index_government_leaders_on_government_id"
    t.index ["user_id"], name: "index_government_leaders_on_user_id"
  end

  create_table "government_political_figures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "political_figure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_id"], name: "index_government_political_figures_on_government_id"
    t.index ["user_id"], name: "index_government_political_figures_on_user_id"
  end

  create_table "government_technologies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "government_id"
    t.integer "technology_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_id"], name: "index_government_technologies_on_government_id"
    t.index ["technology_id"], name: "index_government_technologies_on_technology_id"
    t.index ["user_id"], name: "index_government_technologies_on_user_id"
  end

  create_table "governments", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "type_of_government"
    t.string "power_structure"
    t.string "power_source"
    t.string "checks_and_balances"
    t.string "sociopolitical"
    t.string "socioeconomical"
    t.string "geocultural"
    t.string "laws"
    t.string "immigration"
    t.string "privacy_ideologies"
    t.string "electoral_process"
    t.string "term_lengths"
    t.string "criminal_system"
    t.string "approval_ratings"
    t.string "military"
    t.string "navy"
    t.string "airforce"
    t.string "space_program"
    t.string "international_relations"
    t.string "civilian_life"
    t.string "founding_story"
    t.string "flag_design_story"
    t.string "notable_wars"
    t.string "notes"
    t.string "private_notes"
    t.string "privacy"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page_type", default: "Government"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_governments_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_governments_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_governments_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_governments_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_governments_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_governments_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_governments_on_user_id"
  end

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

  create_table "group_creatures", force: :cascade do |t|
    t.integer "group_id"
    t.integer "creature_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_group_creatures_on_creature_id"
    t.index ["group_id"], name: "index_group_creatures_on_group_id"
    t.index ["user_id"], name: "index_group_creatures_on_user_id"
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
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "organization_structure"
    t.string "motivation"
    t.string "goal"
    t.string "obstacles"
    t.string "risks"
    t.string "inventory"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Group"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_groups_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_groups_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_groups_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_groups_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_groups_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_groups_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_groups_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "headquarterships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "headquarter_id"
  end

  create_table "image_uploads", force: :cascade do |t|
    t.string "privacy"
    t.integer "user_id"
    t.string "content_type"
    t.integer "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "src_file_name"
    t.string "src_content_type"
    t.bigint "src_file_size"
    t.datetime "src_updated_at"
    t.index ["content_type", "content_id"], name: "index_image_uploads_on_content_type_and_content_id"
    t.index ["user_id"], name: "index_image_uploads_on_user_id"
  end

  create_table "integration_authorizations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "application_integration_id", null: false
    t.string "referral_url"
    t.string "ip_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "origin"
    t.string "content_type"
    t.string "user_agent"
    t.string "user_token"
    t.index ["application_integration_id"], name: "index_integration_authorizations_on_application_integration_id"
    t.index ["user_id"], name: "index_integration_authorizations_on_user_id"
  end

  create_table "item_magics", force: :cascade do |t|
    t.integer "item_id"
    t.integer "magic_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_magics_on_item_id"
    t.index ["magic_id"], name: "index_item_magics_on_magic_id"
    t.index ["user_id"], name: "index_item_magics_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_type"
    t.text "description"
    t.string "weight"
    t.string "original_owner"
    t.string "current_owner"
    t.text "made_by"
    t.text "materials"
    t.string "year_made"
    t.text "magic"
    t.text "notes"
    t.text "private_notes"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "privacy", default: "private", null: false
    t.datetime "deleted_at"
    t.string "page_type", default: "Item"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_items_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_items_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_items_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_items_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_items_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_items_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Job"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_jobs_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_jobs_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "key_itemships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "key_item_id"
  end

  create_table "landmark_countries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "landmark_id"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_landmark_countries_on_country_id"
    t.index ["landmark_id"], name: "index_landmark_countries_on_landmark_id"
    t.index ["user_id"], name: "index_landmark_countries_on_user_id"
  end

  create_table "landmark_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "landmark_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_landmark_creatures_on_creature_id"
    t.index ["landmark_id"], name: "index_landmark_creatures_on_landmark_id"
    t.index ["user_id"], name: "index_landmark_creatures_on_user_id"
  end

  create_table "landmark_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "landmark_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flora_id"], name: "index_landmark_floras_on_flora_id"
    t.index ["landmark_id"], name: "index_landmark_floras_on_landmark_id"
    t.index ["user_id"], name: "index_landmark_floras_on_user_id"
  end

  create_table "landmark_nearby_towns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "landmark_id"
    t.integer "nearby_town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landmark_id"], name: "index_landmark_nearby_towns_on_landmark_id"
    t.index ["user_id"], name: "index_landmark_nearby_towns_on_user_id"
  end

  create_table "landmarks", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.integer "universe_id"
    t.string "size"
    t.string "materials"
    t.string "colors"
    t.string "creation_story"
    t.string "established_year"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "privacy"
    t.integer "user_id"
    t.string "page_type", default: "Landmark"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_landmarks_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_landmarks_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_landmarks_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_landmarks_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_landmarks_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_landmarks_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_landmarks_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "other_names"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "history"
    t.string "typology"
    t.string "dialectical_information"
    t.string "register"
    t.string "phonology"
    t.string "grammar"
    t.string "numbers"
    t.string "quantifiers"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Language"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_languages_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_languages_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_languages_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_languages_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_languages_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_languages_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_languages_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_languages_on_user_id"
  end

  create_table "largest_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "largest_city_id"
  end

  create_table "lingualisms", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "spoken_language_id"
    t.index ["spoken_language_id"], name: "index_lingualisms_on_spoken_language_id"
  end

  create_table "location_capital_towns", force: :cascade do |t|
    t.integer "location_id"
    t.integer "capital_town_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_location_capital_towns_on_location_id"
    t.index ["user_id"], name: "index_location_capital_towns_on_user_id"
  end

  create_table "location_landmarks", force: :cascade do |t|
    t.integer "location_id"
    t.integer "landmark_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landmark_id"], name: "index_location_landmarks_on_landmark_id"
    t.index ["location_id"], name: "index_location_landmarks_on_location_id"
    t.index ["user_id"], name: "index_location_landmarks_on_user_id"
  end

  create_table "location_languageships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_largest_towns", force: :cascade do |t|
    t.integer "location_id"
    t.integer "largest_town_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_location_largest_towns_on_location_id"
    t.index ["user_id"], name: "index_location_largest_towns_on_user_id"
  end

  create_table "location_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "leader_id"
  end

  create_table "location_notable_towns", force: :cascade do |t|
    t.integer "location_id"
    t.integer "notable_town_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_location_notable_towns_on_location_id"
    t.index ["user_id"], name: "index_location_notable_towns_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "type_of"
    t.text "description"
    t.string "map_file_name"
    t.string "map_content_type"
    t.integer "map_file_size"
    t.datetime "map_updated_at"
    t.string "population"
    t.string "language"
    t.string "currency"
    t.string "motto"
    t.text "capital"
    t.text "largest_city"
    t.text "notable_cities"
    t.text "area"
    t.text "crops"
    t.text "located_at"
    t.string "established_year"
    t.text "notable_wars"
    t.text "notes"
    t.text "private_notes"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "privacy", default: "private", null: false
    t.string "laws"
    t.string "climate"
    t.string "founding_story"
    t.string "sports"
    t.datetime "deleted_at"
    t.string "page_type", default: "Location"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_locations_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_locations_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_locations_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_locations_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_locations_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_locations_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "lore_believers", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "believer_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_believers_on_lore_id"
    t.index ["user_id"], name: "index_lore_believers_on_user_id"
  end

  create_table "lore_buildings", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "building_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["building_id"], name: "index_lore_buildings_on_building_id"
    t.index ["lore_id"], name: "index_lore_buildings_on_lore_id"
    t.index ["user_id"], name: "index_lore_buildings_on_user_id"
  end

  create_table "lore_characters", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "character_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["character_id"], name: "index_lore_characters_on_character_id"
    t.index ["lore_id"], name: "index_lore_characters_on_lore_id"
    t.index ["user_id"], name: "index_lore_characters_on_user_id"
  end

  create_table "lore_conditions", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "condition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["condition_id"], name: "index_lore_conditions_on_condition_id"
    t.index ["lore_id"], name: "index_lore_conditions_on_lore_id"
    t.index ["user_id"], name: "index_lore_conditions_on_user_id"
  end

  create_table "lore_continents", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "continent_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_lore_continents_on_continent_id"
    t.index ["lore_id"], name: "index_lore_continents_on_lore_id"
    t.index ["user_id"], name: "index_lore_continents_on_user_id"
  end

  create_table "lore_countries", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "country_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_lore_countries_on_country_id"
    t.index ["lore_id"], name: "index_lore_countries_on_lore_id"
    t.index ["user_id"], name: "index_lore_countries_on_user_id"
  end

  create_table "lore_created_traditions", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "created_tradition_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_created_traditions_on_lore_id"
    t.index ["user_id"], name: "index_lore_created_traditions_on_user_id"
  end

  create_table "lore_creatures", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "creature_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creature_id"], name: "index_lore_creatures_on_creature_id"
    t.index ["lore_id"], name: "index_lore_creatures_on_lore_id"
    t.index ["user_id"], name: "index_lore_creatures_on_user_id"
  end

  create_table "lore_deities", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "deity_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deity_id"], name: "index_lore_deities_on_deity_id"
    t.index ["lore_id"], name: "index_lore_deities_on_lore_id"
    t.index ["user_id"], name: "index_lore_deities_on_user_id"
  end

  create_table "lore_floras", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "flora_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["flora_id"], name: "index_lore_floras_on_flora_id"
    t.index ["lore_id"], name: "index_lore_floras_on_lore_id"
    t.index ["user_id"], name: "index_lore_floras_on_user_id"
  end

  create_table "lore_foods", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "food_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["food_id"], name: "index_lore_foods_on_food_id"
    t.index ["lore_id"], name: "index_lore_foods_on_lore_id"
    t.index ["user_id"], name: "index_lore_foods_on_user_id"
  end

  create_table "lore_governments", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "government_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["government_id"], name: "index_lore_governments_on_government_id"
    t.index ["lore_id"], name: "index_lore_governments_on_lore_id"
    t.index ["user_id"], name: "index_lore_governments_on_user_id"
  end

  create_table "lore_groups", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "group_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_lore_groups_on_group_id"
    t.index ["lore_id"], name: "index_lore_groups_on_lore_id"
    t.index ["user_id"], name: "index_lore_groups_on_user_id"
  end

  create_table "lore_jobs", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "job_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["job_id"], name: "index_lore_jobs_on_job_id"
    t.index ["lore_id"], name: "index_lore_jobs_on_lore_id"
    t.index ["user_id"], name: "index_lore_jobs_on_user_id"
  end

  create_table "lore_landmarks", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "landmark_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["landmark_id"], name: "index_lore_landmarks_on_landmark_id"
    t.index ["lore_id"], name: "index_lore_landmarks_on_lore_id"
    t.index ["user_id"], name: "index_lore_landmarks_on_user_id"
  end

  create_table "lore_magics", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "magic_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_magics_on_lore_id"
    t.index ["magic_id"], name: "index_lore_magics_on_magic_id"
    t.index ["user_id"], name: "index_lore_magics_on_user_id"
  end

  create_table "lore_original_languages", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "original_language_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_original_languages_on_lore_id"
    t.index ["user_id"], name: "index_lore_original_languages_on_user_id"
  end

  create_table "lore_planets", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "planet_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_planets_on_lore_id"
    t.index ["planet_id"], name: "index_lore_planets_on_planet_id"
    t.index ["user_id"], name: "index_lore_planets_on_user_id"
  end

  create_table "lore_races", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "race_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_races_on_lore_id"
    t.index ["race_id"], name: "index_lore_races_on_race_id"
    t.index ["user_id"], name: "index_lore_races_on_user_id"
  end

  create_table "lore_related_lores", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "related_lore_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_related_lores_on_lore_id"
    t.index ["user_id"], name: "index_lore_related_lores_on_user_id"
  end

  create_table "lore_religions", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "religion_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_religions_on_lore_id"
    t.index ["religion_id"], name: "index_lore_religions_on_religion_id"
    t.index ["user_id"], name: "index_lore_religions_on_user_id"
  end

  create_table "lore_schools", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "school_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_schools_on_lore_id"
    t.index ["school_id"], name: "index_lore_schools_on_school_id"
    t.index ["user_id"], name: "index_lore_schools_on_user_id"
  end

  create_table "lore_sports", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "sport_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_sports_on_lore_id"
    t.index ["sport_id"], name: "index_lore_sports_on_sport_id"
    t.index ["user_id"], name: "index_lore_sports_on_user_id"
  end

  create_table "lore_technologies", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "technology_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_technologies_on_lore_id"
    t.index ["technology_id"], name: "index_lore_technologies_on_technology_id"
    t.index ["user_id"], name: "index_lore_technologies_on_user_id"
  end

  create_table "lore_towns", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "town_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_towns_on_lore_id"
    t.index ["town_id"], name: "index_lore_towns_on_town_id"
    t.index ["user_id"], name: "index_lore_towns_on_user_id"
  end

  create_table "lore_traditions", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "tradition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_traditions_on_lore_id"
    t.index ["tradition_id"], name: "index_lore_traditions_on_tradition_id"
    t.index ["user_id"], name: "index_lore_traditions_on_user_id"
  end

  create_table "lore_variations", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "variation_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_variations_on_lore_id"
    t.index ["user_id"], name: "index_lore_variations_on_user_id"
  end

  create_table "lore_vehicles", force: :cascade do |t|
    t.integer "lore_id", null: false
    t.integer "vehicle_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lore_id"], name: "index_lore_vehicles_on_lore_id"
    t.index ["user_id"], name: "index_lore_vehicles_on_user_id"
    t.index ["vehicle_id"], name: "index_lore_vehicles_on_vehicle_id"
  end

  create_table "lores", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.datetime "archived_at"
    t.string "privacy"
    t.boolean "favorite", default: false
    t.string "page_type", default: "Lore"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["universe_id"], name: "index_lores_on_universe_id"
    t.index ["user_id"], name: "index_lores_on_user_id"
  end

  create_table "magic_deityships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "magic_id"
    t.integer "deity_id"
  end

  create_table "magics", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "type_of"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "visuals"
    t.string "effects"
    t.string "positive_effects"
    t.string "negative_effects"
    t.string "neutral_effects"
    t.string "element"
    t.string "resource_costs"
    t.string "materials"
    t.string "skills_required"
    t.string "limitations"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Magic"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_magics_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_magics_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_magics_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_magics_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_magics_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_magics_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_magics_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_magics_on_user_id"
  end

  create_table "maker_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "maker_id"
  end

  create_table "marriages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "spouse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "motherships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "mother_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notable_cities_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "notable_city_id"
  end

  create_table "notice_dismissals", force: :cascade do |t|
    t.integer "user_id"
    t.integer "notice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notice_dismissals_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.string "message_html"
    t.string "icon", default: "notifications_active"
    t.datetime "happened_at"
    t.datetime "viewed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon_color", default: "blue"
    t.string "passthrough_link"
    t.string "reference_code"
    t.index ["user_id"], name: "index_notifications_on_user_id"
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
    t.integer "character_id"
    t.integer "item_id"
    t.integer "user_id"
    t.boolean "favorite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_collection_followings", force: :cascade do |t|
    t.integer "page_collection_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_collection_id"], name: "index_page_collection_followings_on_page_collection_id"
    t.index ["user_id"], name: "index_page_collection_followings_on_user_id"
  end

  create_table "page_collection_reports", force: :cascade do |t|
    t.integer "page_collection_id", null: false
    t.integer "user_id", null: false
    t.datetime "approved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_collection_id"], name: "index_page_collection_reports_on_page_collection_id"
    t.index ["user_id"], name: "index_page_collection_reports_on_user_id"
  end

  create_table "page_collection_submissions", force: :cascade do |t|
    t.string "content_type", null: false
    t.integer "content_id", null: false
    t.integer "user_id", null: false
    t.datetime "accepted_at"
    t.datetime "submitted_at"
    t.integer "page_collection_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "explanation"
    t.string "cached_content_name"
    t.datetime "deleted_at"
    t.index ["content_type", "content_id"], name: "polycontent_collection_index"
    t.index ["page_collection_id"], name: "index_page_collection_submissions_on_page_collection_id"
    t.index ["user_id"], name: "index_page_collection_submissions_on_user_id"
  end

  create_table "page_collections", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.integer "user_id", null: false
    t.string "privacy"
    t.string "page_types"
    t.string "color"
    t.string "cover_image"
    t.boolean "auto_accept", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.boolean "allow_submissions", default: false
    t.string "slug"
    t.datetime "deleted_at"
    t.index ["user_id"], name: "index_page_collections_on_user_id"
  end

  create_table "page_references", force: :cascade do |t|
    t.string "referencing_page_type", null: false
    t.integer "referencing_page_id", null: false
    t.string "referenced_page_type", null: false
    t.integer "referenced_page_id", null: false
    t.integer "attribute_field_id"
    t.string "cached_relation_title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reference_type"
    t.index ["attribute_field_id"], name: "index_page_references_on_attribute_field_id"
    t.index ["referenced_page_type", "referenced_page_id"], name: "page_reference_referenced_page"
    t.index ["referencing_page_type", "referencing_page_id"], name: "page_reference_referencing_page"
  end

  create_table "page_settings_overrides", force: :cascade do |t|
    t.string "page_type"
    t.string "name_override"
    t.string "icon_override"
    t.string "hex_color_override"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_page_settings_overrides_on_user_id"
  end

  create_table "page_tags", force: :cascade do |t|
    t.string "page_type"
    t.integer "page_id"
    t.string "tag"
    t.string "slug"
    t.string "color"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_type", "page_id"], name: "index_page_tags_on_page_type_and_page_id"
    t.index ["user_id", "page_type"], name: "index_page_tags_on_user_id_and_page_type"
    t.index ["user_id"], name: "index_page_tags_on_user_id"
  end

  create_table "page_unlock_promo_codes", force: :cascade do |t|
    t.string "code"
    t.string "page_types"
    t.integer "uses_remaining"
    t.integer "days_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "internal_description"
    t.string "description"
  end

  create_table "past_ownerships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "past_owner_id"
  end

  create_table "paypal_invoices", force: :cascade do |t|
    t.string "paypal_id"
    t.string "status"
    t.integer "user_id", null: false
    t.integer "months"
    t.integer "amount_cents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "page_unlock_promo_code_id"
    t.string "approval_url"
    t.string "payer_id"
    t.datetime "deleted_at"
    t.index ["page_unlock_promo_code_id"], name: "index_paypal_invoices_on_page_unlock_promo_code_id"
    t.index ["user_id"], name: "index_paypal_invoices_on_user_id"
  end

  create_table "planet_continents", force: :cascade do |t|
    t.integer "planet_id", null: false
    t.integer "continent_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["continent_id"], name: "index_planet_continents_on_continent_id"
    t.index ["planet_id"], name: "index_planet_continents_on_planet_id"
    t.index ["user_id"], name: "index_planet_continents_on_user_id"
  end

  create_table "planet_countries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_planet_countries_on_country_id"
    t.index ["planet_id"], name: "index_planet_countries_on_planet_id"
    t.index ["user_id"], name: "index_planet_countries_on_user_id"
  end

  create_table "planet_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_planet_creatures_on_creature_id"
    t.index ["planet_id"], name: "index_planet_creatures_on_planet_id"
    t.index ["user_id"], name: "index_planet_creatures_on_user_id"
  end

  create_table "planet_deities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "deity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_planet_deities_on_deity_id"
    t.index ["planet_id"], name: "index_planet_deities_on_planet_id"
    t.index ["user_id"], name: "index_planet_deities_on_user_id"
  end

  create_table "planet_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flora_id"], name: "index_planet_floras_on_flora_id"
    t.index ["planet_id"], name: "index_planet_floras_on_planet_id"
    t.index ["user_id"], name: "index_planet_floras_on_user_id"
  end

  create_table "planet_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_planet_groups_on_group_id"
    t.index ["planet_id"], name: "index_planet_groups_on_planet_id"
    t.index ["user_id"], name: "index_planet_groups_on_user_id"
  end

  create_table "planet_landmarks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "landmark_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landmark_id"], name: "index_planet_landmarks_on_landmark_id"
    t.index ["planet_id"], name: "index_planet_landmarks_on_planet_id"
    t.index ["user_id"], name: "index_planet_landmarks_on_user_id"
  end

  create_table "planet_languages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_planet_languages_on_language_id"
    t.index ["planet_id"], name: "index_planet_languages_on_planet_id"
    t.index ["user_id"], name: "index_planet_languages_on_user_id"
  end

  create_table "planet_locations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_planet_locations_on_location_id"
    t.index ["planet_id"], name: "index_planet_locations_on_planet_id"
    t.index ["user_id"], name: "index_planet_locations_on_user_id"
  end

  create_table "planet_nearby_planets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "nearby_planet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_planet_nearby_planets_on_planet_id"
    t.index ["user_id"], name: "index_planet_nearby_planets_on_user_id"
  end

  create_table "planet_races", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "race_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_planet_races_on_planet_id"
    t.index ["race_id"], name: "index_planet_races_on_race_id"
    t.index ["user_id"], name: "index_planet_races_on_user_id"
  end

  create_table "planet_religions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "religion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_planet_religions_on_planet_id"
    t.index ["religion_id"], name: "index_planet_religions_on_religion_id"
    t.index ["user_id"], name: "index_planet_religions_on_user_id"
  end

  create_table "planet_towns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "planet_id"
    t.integer "town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_planet_towns_on_planet_id"
    t.index ["town_id"], name: "index_planet_towns_on_town_id"
    t.index ["user_id"], name: "index_planet_towns_on_user_id"
  end

  create_table "planets", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "size"
    t.string "surface"
    t.string "climate"
    t.string "weather"
    t.string "water_content"
    t.string "natural_resources"
    t.string "length_of_day"
    t.string "length_of_night"
    t.string "calendar_system"
    t.string "population"
    t.string "moons"
    t.string "orbit"
    t.string "visible_constellations"
    t.string "first_inhabitants_story"
    t.string "world_history"
    t.string "private_notes"
    t.string "privacy"
    t.integer "universe_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes"
    t.string "page_type", default: "Planet"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_planets_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_planets_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_planets_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_planets_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_planets_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_planets_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_planets_on_user_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "page_unlock_promo_code_id"
    t.datetime "expires_at"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_unlock_promo_code_id"], name: "index_promotions_on_page_unlock_promo_code_id"
    t.index ["user_id", "expires_at"], name: "index_promotions_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_promotions_on_user_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "body_shape"
    t.string "skin_colors"
    t.string "height"
    t.string "weight"
    t.string "notable_features"
    t.string "variance"
    t.string "clothing"
    t.string "strengths"
    t.string "weaknesses"
    t.string "traditions"
    t.string "beliefs"
    t.string "governments"
    t.string "technologies"
    t.string "occupations"
    t.string "economics"
    t.string "favorite_foods"
    t.string "notable_events"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Race"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_races_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_races_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_races_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_races_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_races_on_id_and_deleted_at"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_races_on_user_id_and_universe_id_and_deleted_at"
  end

  create_table "raceships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "race_id"
  end

  create_table "raffle_entries", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_raffle_entries_on_user_id"
  end

  create_table "referral_codes", force: :cascade do |t|
    t.integer "user_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_referral_codes_on_user_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.integer "referrer_id"
    t.integer "referred_id"
    t.integer "associated_code_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "religion_deities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "religion_id"
    t.integer "deity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deity_id"], name: "index_religion_deities_on_deity_id"
    t.index ["religion_id"], name: "index_religion_deities_on_religion_id"
    t.index ["user_id"], name: "index_religion_deities_on_user_id"
  end

  create_table "religions", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "origin_story"
    t.string "teachings"
    t.string "prophecies"
    t.string "places_of_worship"
    t.string "worship_services"
    t.string "obligations"
    t.string "paradise"
    t.string "initiation"
    t.string "rituals"
    t.string "holidays"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Religion"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_religions_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_religions_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_religions_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_religions_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_religions_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_religions_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_religions_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_religions_on_user_id"
  end

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
    t.integer "scene_number"
    t.string "name"
    t.string "summary"
    t.integer "universe_id"
    t.integer "user_id"
    t.string "cause"
    t.string "description"
    t.string "results"
    t.string "prose"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "privacy"
    t.datetime "deleted_at"
    t.string "page_type", default: "Scene"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_scenes_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_scenes_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_scenes_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_scenes_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_scenes_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_scenes_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_scenes_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_scenes_on_user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "School"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_schools_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_schools_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_schools_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "username", null: false
    t.string "password", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "content_page_share_id", null: false
    t.string "message"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_page_share_id"], name: "index_share_comments_on_content_page_share_id"
    t.index ["user_id"], name: "index_share_comments_on_user_id"
  end

  create_table "siblingships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "character_id"
    t.integer "sibling_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sistergroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "sistergroup_id"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Sport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_sports_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_sports_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_sports_on_user_id"
  end

  create_table "stripe_event_logs", force: :cascade do |t|
    t.string "event_id"
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subgroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "subgroup_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "billing_plan_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_plan_id"], name: "index_subscriptions_on_billing_plan_id"
    t.index ["user_id", "start_date", "end_date"], name: "index_subscriptions_on_user_id_and_start_date_and_end_date"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "supergroupships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "supergroup_id"
  end

  create_table "technologies", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.string "materials"
    t.string "manufacturing_process"
    t.string "sales_process"
    t.string "cost"
    t.string "rarity"
    t.string "purpose"
    t.string "how_it_works"
    t.string "resources_used"
    t.string "physical_description"
    t.string "size"
    t.string "weight"
    t.string "colors"
    t.string "notes"
    t.string "private_notes"
    t.string "privacy"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page_type", default: "Technology"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_technologies_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_technologies_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_technologies_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_technologies_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_technologies_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_technologies_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_technologies_on_user_id"
  end

  create_table "technology_characters", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_technology_characters_on_character_id"
    t.index ["technology_id"], name: "index_technology_characters_on_technology_id"
    t.index ["user_id"], name: "index_technology_characters_on_user_id"
  end

  create_table "technology_child_technologies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "child_technology_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technology_id"], name: "index_technology_child_technologies_on_technology_id"
    t.index ["user_id"], name: "index_technology_child_technologies_on_user_id"
  end

  create_table "technology_countries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_technology_countries_on_country_id"
    t.index ["technology_id"], name: "index_technology_countries_on_technology_id"
    t.index ["user_id"], name: "index_technology_countries_on_user_id"
  end

  create_table "technology_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_technology_creatures_on_creature_id"
    t.index ["technology_id"], name: "index_technology_creatures_on_technology_id"
    t.index ["user_id"], name: "index_technology_creatures_on_user_id"
  end

  create_table "technology_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_technology_groups_on_group_id"
    t.index ["technology_id"], name: "index_technology_groups_on_technology_id"
    t.index ["user_id"], name: "index_technology_groups_on_user_id"
  end

  create_table "technology_magics", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "magic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["magic_id"], name: "index_technology_magics_on_magic_id"
    t.index ["technology_id"], name: "index_technology_magics_on_technology_id"
    t.index ["user_id"], name: "index_technology_magics_on_user_id"
  end

  create_table "technology_parent_technologies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "parent_technology_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technology_id"], name: "index_technology_parent_technologies_on_technology_id"
    t.index ["user_id"], name: "index_technology_parent_technologies_on_user_id"
  end

  create_table "technology_planets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "planet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_technology_planets_on_planet_id"
    t.index ["technology_id"], name: "index_technology_planets_on_technology_id"
    t.index ["user_id"], name: "index_technology_planets_on_user_id"
  end

  create_table "technology_related_technologies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "related_technology_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technology_id"], name: "index_technology_related_technologies_on_technology_id"
    t.index ["user_id"], name: "index_technology_related_technologies_on_user_id"
  end

  create_table "technology_towns", force: :cascade do |t|
    t.integer "user_id"
    t.integer "technology_id"
    t.integer "town_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technology_id"], name: "index_technology_towns_on_technology_id"
    t.index ["town_id"], name: "index_technology_towns_on_town_id"
    t.index ["user_id"], name: "index_technology_towns_on_user_id"
  end

  create_table "thredded_categories", force: :cascade do |t|
    t.integer "messageboard_id", null: false
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug", null: false
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
    t.index ["name"], name: "thredded_categories_name_ci"
  end

  create_table "thredded_messageboard_groups", force: :cascade do |t|
    t.string "name"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_messageboard_notifications_for_followed_topics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "messageboard_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "messageboard_id", "notifier_key"], name: "thredded_messageboard_notifications_for_followed_topics_unique", unique: true
  end

  create_table "thredded_messageboard_users", force: :cascade do |t|
    t.integer "thredded_user_detail_id", null: false
    t.integer "thredded_messageboard_id", null: false
    t.datetime "last_seen_at", null: false
    t.index ["thredded_messageboard_id", "last_seen_at"], name: "index_thredded_messageboard_users_for_recently_active"
    t.index ["thredded_messageboard_id", "thredded_user_detail_id"], name: "index_thredded_messageboard_users_primary", unique: true
  end

  create_table "thredded_messageboards", force: :cascade do |t|
    t.text "name", null: false
    t.text "slug"
    t.text "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.integer "position", null: false
    t.integer "last_topic_id"
    t.integer "messageboard_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false, null: false
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug", unique: true
  end

  create_table "thredded_notifications_for_followed_topics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "notifier_key"], name: "thredded_notifications_for_followed_topics_unique", unique: true
  end

  create_table "thredded_notifications_for_private_topics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "notifier_key"], name: "thredded_notifications_for_private_topics_unique", unique: true
  end

  create_table "thredded_post_moderation_records", force: :cascade do |t|
    t.integer "post_id"
    t.integer "messageboard_id"
    t.text "post_content", limit: 65535
    t.integer "post_user_id"
    t.text "post_user_name"
    t.integer "moderator_id"
    t.integer "moderation_state", null: false
    t.integer "previous_moderation_state", null: false
    t.datetime "created_at", null: false
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
  end

  create_table "thredded_posts", force: :cascade do |t|
    t.integer "user_id"
    t.text "content", limit: 65535
    t.string "source", limit: 191, default: "web"
    t.integer "postable_id", null: false
    t.integer "messageboard_id", null: false
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at", "messageboard_id"], name: "index_thredded_posts_on_deleted_at_and_messageboard_id"
    t.index ["deleted_at", "postable_id"], name: "index_thredded_posts_on_deleted_at_and_postable_id"
    t.index ["deleted_at", "user_id"], name: "index_thredded_posts_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_thredded_posts_on_deleted_at"
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
  end

  create_table "thredded_private_posts", force: :cascade do |t|
    t.integer "user_id"
    t.text "content", limit: 65535
    t.integer "postable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["postable_id", "created_at"], name: "index_thredded_private_posts_on_postable_id_and_created_at"
  end

  create_table "thredded_private_topics", force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.text "title", null: false
    t.text "slug", null: false
    t.integer "posts_count", default: 0
    t.string "hash_id", limit: 20, null: false
    t.datetime "last_post_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["last_post_at"], name: "index_thredded_private_topics_on_last_post_at"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug", unique: true
  end

  create_table "thredded_private_users", force: :cascade do |t|
    t.integer "private_topic_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
  end

  create_table "thredded_topic_categories", force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "category_id", null: false
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
  end

  create_table "thredded_topics", force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.text "title", null: false
    t.text "slug", null: false
    t.integer "messageboard_id", null: false
    t.integer "posts_count", default: 0, null: false
    t.boolean "sticky", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.string "hash_id", limit: 20, null: false
    t.integer "moderation_state", null: false
    t.datetime "last_post_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at", "messageboard_id"], name: "index_thredded_topics_on_deleted_at_and_messageboard_id"
    t.index ["deleted_at", "user_id"], name: "index_thredded_topics_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_thredded_topics_on_deleted_at"
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["last_post_at"], name: "index_thredded_topics_on_last_post_at"
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display"
    t.index ["slug"], name: "index_thredded_topics_on_slug", unique: true
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
  end

  create_table "thredded_user_details", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "latest_activity_at"
    t.integer "posts_count", default: 0
    t.integer "topics_count", default: 0
    t.datetime "last_seen_at"
    t.integer "moderation_state", default: 1, null: false
    t.datetime "moderation_state_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations"
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id", unique: true
  end

  create_table "thredded_user_messageboard_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "messageboard_id", null: false
    t.boolean "follow_topics_on_mention", default: true, null: false
    t.boolean "auto_follow_topics", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
  end

  create_table "thredded_user_post_notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "post_id", null: false
    t.datetime "notified_at", null: false
    t.index ["post_id"], name: "index_thredded_user_post_notifications_on_post_id"
    t.index ["user_id", "post_id"], name: "index_thredded_user_post_notifications_on_user_id_and_post_id", unique: true
  end

  create_table "thredded_user_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "follow_topics_on_mention", default: true, null: false
    t.boolean "auto_follow_topics", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id", unique: true
  end

  create_table "thredded_user_private_topic_read_states", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.datetime "read_at", null: false
    t.integer "unread_posts_count", default: 0, null: false
    t.integer "read_posts_count", default: 0, null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
  end

  create_table "thredded_user_topic_follows", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.integer "reason", limit: 1
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
  end

  create_table "thredded_user_topic_read_states", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.datetime "read_at", null: false
    t.integer "unread_posts_count", default: 0, null: false
    t.integer "read_posts_count", default: 0, null: false
    t.integer "messageboard_id", null: false
    t.index ["messageboard_id"], name: "index_thredded_user_topic_read_states_on_messageboard_id"
    t.index ["user_id", "messageboard_id"], name: "thredded_user_topic_read_states_user_messageboard"
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
  end

  create_table "timeline_event_entities", force: :cascade do |t|
    t.string "entity_type", null: false
    t.integer "entity_id", null: false
    t.integer "timeline_event_id", null: false
    t.string "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entity_type", "entity_id"], name: "index_timeline_event_entities_on_entity_type_and_entity_id"
    t.index ["timeline_event_id"], name: "index_timeline_event_entities_on_timeline_event_id"
  end

  create_table "timeline_events", force: :cascade do |t|
    t.integer "timeline_id", null: false
    t.string "time_label"
    t.string "title"
    t.string "description"
    t.string "notes"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["timeline_id"], name: "index_timeline_events_on_timeline_id"
  end

  create_table "timelines", force: :cascade do |t|
    t.string "name"
    t.integer "universe_id"
    t.integer "user_id", null: false
    t.string "page_type", default: "Timeline"
    t.datetime "deleted_at"
    t.datetime "archived_at"
    t.string "privacy", default: "private"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.string "subtitle"
    t.string "notes"
    t.string "private_notes"
    t.boolean "favorite", default: false
    t.index ["universe_id"], name: "index_timelines_on_universe_id"
    t.index ["user_id"], name: "index_timelines_on_user_id"
  end

  create_table "town_citizens", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "citizen_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["town_id"], name: "index_town_citizens_on_town_id"
    t.index ["user_id"], name: "index_town_citizens_on_user_id"
  end

  create_table "town_countries", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_town_countries_on_country_id"
    t.index ["town_id"], name: "index_town_countries_on_town_id"
    t.index ["user_id"], name: "index_town_countries_on_user_id"
  end

  create_table "town_creatures", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "creature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creature_id"], name: "index_town_creatures_on_creature_id"
    t.index ["town_id"], name: "index_town_creatures_on_town_id"
    t.index ["user_id"], name: "index_town_creatures_on_user_id"
  end

  create_table "town_floras", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "flora_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flora_id"], name: "index_town_floras_on_flora_id"
    t.index ["town_id"], name: "index_town_floras_on_town_id"
    t.index ["user_id"], name: "index_town_floras_on_user_id"
  end

  create_table "town_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_town_groups_on_group_id"
    t.index ["town_id"], name: "index_town_groups_on_town_id"
    t.index ["user_id"], name: "index_town_groups_on_user_id"
  end

  create_table "town_languages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_town_languages_on_language_id"
    t.index ["town_id"], name: "index_town_languages_on_town_id"
    t.index ["user_id"], name: "index_town_languages_on_user_id"
  end

  create_table "town_nearby_landmarks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "town_id"
    t.integer "nearby_landmark_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["town_id"], name: "index_town_nearby_landmarks_on_town_id"
    t.index ["user_id"], name: "index_town_nearby_landmarks_on_user_id"
  end

  create_table "towns", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "other_names"
    t.string "laws"
    t.string "sports"
    t.string "politics"
    t.string "founding_story"
    t.string "established_year"
    t.string "notes"
    t.string "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.integer "user_id"
    t.string "page_type", default: "Town"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_towns_on_deleted_at_and_id"
    t.index ["deleted_at", "universe_id"], name: "index_towns_on_deleted_at_and_universe_id"
    t.index ["deleted_at", "user_id"], name: "index_towns_on_deleted_at_and_user_id"
    t.index ["id", "deleted_at"], name: "index_towns_on_id_and_deleted_at"
    t.index ["universe_id"], name: "index_towns_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_towns_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_towns_on_user_id"
  end

  create_table "traditions", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Tradition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_traditions_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_traditions_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_traditions_on_user_id"
  end

  create_table "universes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "history"
    t.text "notes"
    t.text "private_notes"
    t.string "privacy"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "laws_of_physics"
    t.string "magic_system"
    t.string "technology"
    t.string "genre"
    t.datetime "deleted_at"
    t.string "page_type", default: "Universe"
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["deleted_at", "id"], name: "index_universes_on_deleted_at_and_id"
    t.index ["deleted_at", "user_id"], name: "index_universes_on_deleted_at_and_user_id"
    t.index ["deleted_at"], name: "index_universes_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_universes_on_id_and_deleted_at"
    t.index ["user_id"], name: "index_universes_on_user_id"
  end

  create_table "user_blockings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "blocked_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blocked_user_id"], name: "index_user_blockings_on_blocked_user_id"
    t.index ["user_id"], name: "index_user_blockings_on_user_id"
  end

  create_table "user_content_type_activators", force: :cascade do |t|
    t.integer "user_id"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_content_type_activators_on_user_id"
  end

  create_table "user_followings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "followed_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_user_id"], name: "index_user_followings_on_followed_user_id"
    t.index ["user_id"], name: "index_user_followings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "old_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "plan_type"
    t.string "stripe_customer_id"
    t.boolean "email_updates", default: true
    t.integer "selected_billing_plan_id"
    t.integer "upload_bandwidth_kb", default: 50000
    t.string "secure_code"
    t.boolean "fluid_preference"
    t.string "username"
    t.boolean "forum_administrator", default: false, null: false
    t.datetime "deleted_at"
    t.boolean "site_administrator", default: false
    t.boolean "forum_moderator", default: false
    t.string "bio"
    t.string "favorite_author"
    t.string "favorite_genre"
    t.string "location"
    t.string "age"
    t.string "gender"
    t.string "interests"
    t.string "forums_badge_text"
    t.boolean "keyboard_shortcuts_preference"
    t.string "favorite_book"
    t.string "website"
    t.string "inspirations"
    t.string "other_names"
    t.string "favorite_quote"
    t.string "occupation"
    t.string "favorite_page_type"
    t.boolean "dark_mode_enabled"
    t.boolean "notification_updates", default: true
    t.boolean "community_features_enabled", default: true
    t.boolean "private_profile", default: false
    t.boolean "enabled_april_fools"
    t.index ["deleted_at", "username"], name: "index_users_on_deleted_at_and_username"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["id", "deleted_at"], name: "index_users_on_id_and_deleted_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "universe_id"
    t.datetime "deleted_at"
    t.string "privacy"
    t.string "page_type", default: "Vehicle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.boolean "favorite", default: false
    t.boolean "columns_migrated_from_old_style", default: true
    t.index ["universe_id"], name: "index_vehicles_on_universe_id"
    t.index ["user_id", "universe_id", "deleted_at"], name: "index_vehicles_on_user_id_and_universe_id_and_deleted_at"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  create_table "votables", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "icon"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "votable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["votable_id"], name: "index_votes_on_votable_id"
  end

  create_table "wildlifeships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "creature_id"
    t.integer "habitat_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "users"
  add_foreign_key "api_requests", "application_integrations"
  add_foreign_key "api_requests", "integration_authorizations"
  add_foreign_key "application_integrations", "users"
  add_foreign_key "buildings", "universes"
  add_foreign_key "buildings", "users"
  add_foreign_key "character_birthtowns", "characters"
  add_foreign_key "character_birthtowns", "users"
  add_foreign_key "character_companions", "characters"
  add_foreign_key "character_companions", "users"
  add_foreign_key "character_enemies", "characters"
  add_foreign_key "character_enemies", "users"
  add_foreign_key "character_floras", "characters"
  add_foreign_key "character_floras", "floras"
  add_foreign_key "character_floras", "users"
  add_foreign_key "character_friends", "characters"
  add_foreign_key "character_friends", "users"
  add_foreign_key "character_items", "characters"
  add_foreign_key "character_items", "items"
  add_foreign_key "character_items", "users"
  add_foreign_key "character_love_interests", "characters"
  add_foreign_key "character_love_interests", "users"
  add_foreign_key "character_magics", "characters"
  add_foreign_key "character_magics", "magics"
  add_foreign_key "character_magics", "users"
  add_foreign_key "character_technologies", "characters"
  add_foreign_key "character_technologies", "technologies"
  add_foreign_key "character_technologies", "users"
  add_foreign_key "conditions", "universes"
  add_foreign_key "conditions", "users"
  add_foreign_key "content_change_events", "users"
  add_foreign_key "content_page_share_followings", "content_page_shares"
  add_foreign_key "content_page_share_followings", "users"
  add_foreign_key "content_page_share_reports", "content_page_shares"
  add_foreign_key "content_page_share_reports", "users"
  add_foreign_key "content_page_shares", "users"
  add_foreign_key "content_pages", "universes"
  add_foreign_key "content_pages", "users"
  add_foreign_key "continent_countries", "continents"
  add_foreign_key "continent_countries", "countries"
  add_foreign_key "continent_countries", "users"
  add_foreign_key "continent_creatures", "continents"
  add_foreign_key "continent_creatures", "creatures"
  add_foreign_key "continent_creatures", "users"
  add_foreign_key "continent_floras", "continents"
  add_foreign_key "continent_floras", "floras"
  add_foreign_key "continent_floras", "users"
  add_foreign_key "continent_governments", "continents"
  add_foreign_key "continent_governments", "governments"
  add_foreign_key "continent_governments", "users"
  add_foreign_key "continent_landmarks", "continents"
  add_foreign_key "continent_landmarks", "landmarks"
  add_foreign_key "continent_landmarks", "users"
  add_foreign_key "continent_languages", "continents"
  add_foreign_key "continent_languages", "languages"
  add_foreign_key "continent_languages", "users"
  add_foreign_key "continent_popular_foods", "continents"
  add_foreign_key "continent_popular_foods", "users"
  add_foreign_key "continent_traditions", "continents"
  add_foreign_key "continent_traditions", "traditions"
  add_foreign_key "continent_traditions", "users"
  add_foreign_key "continents", "universes"
  add_foreign_key "continents", "users"
  add_foreign_key "contributors", "universes"
  add_foreign_key "contributors", "users"
  add_foreign_key "countries", "universes"
  add_foreign_key "countries", "users"
  add_foreign_key "country_bordering_countries", "countries"
  add_foreign_key "country_bordering_countries", "users"
  add_foreign_key "country_creatures", "countries"
  add_foreign_key "country_creatures", "creatures"
  add_foreign_key "country_creatures", "users"
  add_foreign_key "country_floras", "countries"
  add_foreign_key "country_floras", "floras"
  add_foreign_key "country_floras", "users"
  add_foreign_key "country_governments", "countries"
  add_foreign_key "country_governments", "governments"
  add_foreign_key "country_governments", "users"
  add_foreign_key "country_landmarks", "countries"
  add_foreign_key "country_landmarks", "landmarks"
  add_foreign_key "country_landmarks", "users"
  add_foreign_key "country_languages", "countries"
  add_foreign_key "country_languages", "languages"
  add_foreign_key "country_languages", "users"
  add_foreign_key "country_locations", "countries"
  add_foreign_key "country_locations", "locations"
  add_foreign_key "country_locations", "users"
  add_foreign_key "country_religions", "countries"
  add_foreign_key "country_religions", "religions"
  add_foreign_key "country_religions", "users"
  add_foreign_key "country_towns", "countries"
  add_foreign_key "country_towns", "towns"
  add_foreign_key "country_towns", "users"
  add_foreign_key "deities", "universes"
  add_foreign_key "deities", "users"
  add_foreign_key "deity_abilities", "deities"
  add_foreign_key "deity_abilities", "users"
  add_foreign_key "deity_character_children", "deities"
  add_foreign_key "deity_character_children", "users"
  add_foreign_key "deity_character_parents", "deities"
  add_foreign_key "deity_character_parents", "users"
  add_foreign_key "deity_character_partners", "deities"
  add_foreign_key "deity_character_partners", "users"
  add_foreign_key "deity_character_siblings", "deities"
  add_foreign_key "deity_character_siblings", "users"
  add_foreign_key "deity_creatures", "creatures"
  add_foreign_key "deity_creatures", "deities"
  add_foreign_key "deity_creatures", "users"
  add_foreign_key "deity_deity_children", "deities"
  add_foreign_key "deity_deity_children", "users"
  add_foreign_key "deity_deity_parents", "deities"
  add_foreign_key "deity_deity_parents", "users"
  add_foreign_key "deity_deity_partners", "deities"
  add_foreign_key "deity_deity_partners", "users"
  add_foreign_key "deity_deity_siblings", "deities"
  add_foreign_key "deity_deity_siblings", "users"
  add_foreign_key "deity_floras", "deities"
  add_foreign_key "deity_floras", "floras"
  add_foreign_key "deity_floras", "users"
  add_foreign_key "deity_races", "deities"
  add_foreign_key "deity_races", "races"
  add_foreign_key "deity_races", "users"
  add_foreign_key "deity_related_landmarks", "deities"
  add_foreign_key "deity_related_landmarks", "users"
  add_foreign_key "deity_related_towns", "deities"
  add_foreign_key "deity_related_towns", "users"
  add_foreign_key "deity_relics", "deities"
  add_foreign_key "deity_relics", "users"
  add_foreign_key "deity_religions", "deities"
  add_foreign_key "deity_religions", "religions"
  add_foreign_key "deity_religions", "users"
  add_foreign_key "document_analyses", "documents"
  add_foreign_key "document_categories", "document_analyses"
  add_foreign_key "document_concepts", "document_analyses"
  add_foreign_key "document_entities", "document_analyses"
  add_foreign_key "document_revisions", "documents"
  add_foreign_key "documents", "folders"
  add_foreign_key "documents", "universes"
  add_foreign_key "documents", "users"
  add_foreign_key "floras", "universes"
  add_foreign_key "floras", "users"
  add_foreign_key "folders", "folders", column: "parent_folder_id"
  add_foreign_key "folders", "users"
  add_foreign_key "foods", "universes"
  add_foreign_key "foods", "users"
  add_foreign_key "government_creatures", "creatures"
  add_foreign_key "government_creatures", "governments"
  add_foreign_key "government_creatures", "users"
  add_foreign_key "government_groups", "governments"
  add_foreign_key "government_groups", "groups"
  add_foreign_key "government_groups", "users"
  add_foreign_key "government_items", "governments"
  add_foreign_key "government_items", "items"
  add_foreign_key "government_items", "users"
  add_foreign_key "government_leaders", "governments"
  add_foreign_key "government_leaders", "users"
  add_foreign_key "government_political_figures", "governments"
  add_foreign_key "government_political_figures", "users"
  add_foreign_key "government_technologies", "governments"
  add_foreign_key "government_technologies", "technologies"
  add_foreign_key "government_technologies", "users"
  add_foreign_key "governments", "universes"
  add_foreign_key "governments", "users"
  add_foreign_key "group_creatures", "creatures"
  add_foreign_key "group_creatures", "groups"
  add_foreign_key "group_creatures", "users"
  add_foreign_key "image_uploads", "users"
  add_foreign_key "integration_authorizations", "application_integrations"
  add_foreign_key "integration_authorizations", "users"
  add_foreign_key "item_magics", "items"
  add_foreign_key "item_magics", "magics"
  add_foreign_key "item_magics", "users"
  add_foreign_key "jobs", "universes"
  add_foreign_key "jobs", "users"
  add_foreign_key "landmark_countries", "countries"
  add_foreign_key "landmark_countries", "landmarks"
  add_foreign_key "landmark_countries", "users"
  add_foreign_key "landmark_creatures", "creatures"
  add_foreign_key "landmark_creatures", "landmarks"
  add_foreign_key "landmark_creatures", "users"
  add_foreign_key "landmark_floras", "floras"
  add_foreign_key "landmark_floras", "landmarks"
  add_foreign_key "landmark_floras", "users"
  add_foreign_key "landmark_nearby_towns", "landmarks"
  add_foreign_key "landmark_nearby_towns", "users"
  add_foreign_key "landmarks", "universes"
  add_foreign_key "landmarks", "users"
  add_foreign_key "location_capital_towns", "locations"
  add_foreign_key "location_capital_towns", "users"
  add_foreign_key "location_landmarks", "landmarks"
  add_foreign_key "location_landmarks", "locations"
  add_foreign_key "location_landmarks", "users"
  add_foreign_key "location_largest_towns", "locations"
  add_foreign_key "location_largest_towns", "users"
  add_foreign_key "location_notable_towns", "locations"
  add_foreign_key "location_notable_towns", "users"
  add_foreign_key "lore_believers", "lores"
  add_foreign_key "lore_believers", "users"
  add_foreign_key "lore_buildings", "buildings"
  add_foreign_key "lore_buildings", "lores"
  add_foreign_key "lore_buildings", "users"
  add_foreign_key "lore_characters", "characters"
  add_foreign_key "lore_characters", "lores"
  add_foreign_key "lore_characters", "users"
  add_foreign_key "lore_conditions", "conditions"
  add_foreign_key "lore_conditions", "lores"
  add_foreign_key "lore_conditions", "users"
  add_foreign_key "lore_continents", "continents"
  add_foreign_key "lore_continents", "lores"
  add_foreign_key "lore_continents", "users"
  add_foreign_key "lore_countries", "countries"
  add_foreign_key "lore_countries", "lores"
  add_foreign_key "lore_countries", "users"
  add_foreign_key "lore_created_traditions", "lores"
  add_foreign_key "lore_created_traditions", "users"
  add_foreign_key "lore_creatures", "creatures"
  add_foreign_key "lore_creatures", "lores"
  add_foreign_key "lore_creatures", "users"
  add_foreign_key "lore_deities", "deities"
  add_foreign_key "lore_deities", "lores"
  add_foreign_key "lore_deities", "users"
  add_foreign_key "lore_floras", "floras"
  add_foreign_key "lore_floras", "lores"
  add_foreign_key "lore_floras", "users"
  add_foreign_key "lore_foods", "foods"
  add_foreign_key "lore_foods", "lores"
  add_foreign_key "lore_foods", "users"
  add_foreign_key "lore_governments", "governments"
  add_foreign_key "lore_governments", "lores"
  add_foreign_key "lore_governments", "users"
  add_foreign_key "lore_groups", "groups"
  add_foreign_key "lore_groups", "lores"
  add_foreign_key "lore_groups", "users"
  add_foreign_key "lore_jobs", "jobs"
  add_foreign_key "lore_jobs", "lores"
  add_foreign_key "lore_jobs", "users"
  add_foreign_key "lore_landmarks", "landmarks"
  add_foreign_key "lore_landmarks", "lores"
  add_foreign_key "lore_landmarks", "users"
  add_foreign_key "lore_magics", "lores"
  add_foreign_key "lore_magics", "magics"
  add_foreign_key "lore_magics", "users"
  add_foreign_key "lore_original_languages", "lores"
  add_foreign_key "lore_original_languages", "users"
  add_foreign_key "lore_planets", "lores"
  add_foreign_key "lore_planets", "planets"
  add_foreign_key "lore_planets", "users"
  add_foreign_key "lore_races", "lores"
  add_foreign_key "lore_races", "races"
  add_foreign_key "lore_races", "users"
  add_foreign_key "lore_related_lores", "lores"
  add_foreign_key "lore_related_lores", "users"
  add_foreign_key "lore_religions", "lores"
  add_foreign_key "lore_religions", "religions"
  add_foreign_key "lore_religions", "users"
  add_foreign_key "lore_schools", "lores"
  add_foreign_key "lore_schools", "schools"
  add_foreign_key "lore_schools", "users"
  add_foreign_key "lore_sports", "lores"
  add_foreign_key "lore_sports", "sports"
  add_foreign_key "lore_sports", "users"
  add_foreign_key "lore_technologies", "lores"
  add_foreign_key "lore_technologies", "technologies"
  add_foreign_key "lore_technologies", "users"
  add_foreign_key "lore_towns", "lores"
  add_foreign_key "lore_towns", "towns"
  add_foreign_key "lore_towns", "users"
  add_foreign_key "lore_traditions", "lores"
  add_foreign_key "lore_traditions", "traditions"
  add_foreign_key "lore_traditions", "users"
  add_foreign_key "lore_variations", "lores"
  add_foreign_key "lore_variations", "users"
  add_foreign_key "lore_vehicles", "lores"
  add_foreign_key "lore_vehicles", "users"
  add_foreign_key "lore_vehicles", "vehicles"
  add_foreign_key "lores", "universes"
  add_foreign_key "lores", "users"
  add_foreign_key "notice_dismissals", "users"
  add_foreign_key "page_collection_followings", "page_collections"
  add_foreign_key "page_collection_followings", "users"
  add_foreign_key "page_collection_reports", "page_collections"
  add_foreign_key "page_collection_reports", "users"
  add_foreign_key "page_collection_submissions", "users"
  add_foreign_key "page_collections", "users"
  add_foreign_key "page_references", "attribute_fields"
  add_foreign_key "page_tags", "users"
  add_foreign_key "paypal_invoices", "page_unlock_promo_codes"
  add_foreign_key "paypal_invoices", "users"
  add_foreign_key "planet_continents", "continents"
  add_foreign_key "planet_continents", "planets"
  add_foreign_key "planet_continents", "users"
  add_foreign_key "planet_countries", "countries"
  add_foreign_key "planet_countries", "planets"
  add_foreign_key "planet_countries", "users"
  add_foreign_key "planet_creatures", "creatures"
  add_foreign_key "planet_creatures", "planets"
  add_foreign_key "planet_creatures", "users"
  add_foreign_key "planet_deities", "deities"
  add_foreign_key "planet_deities", "planets"
  add_foreign_key "planet_deities", "users"
  add_foreign_key "planet_floras", "floras"
  add_foreign_key "planet_floras", "planets"
  add_foreign_key "planet_floras", "users"
  add_foreign_key "planet_groups", "groups"
  add_foreign_key "planet_groups", "planets"
  add_foreign_key "planet_groups", "users"
  add_foreign_key "planet_landmarks", "landmarks"
  add_foreign_key "planet_landmarks", "planets"
  add_foreign_key "planet_landmarks", "users"
  add_foreign_key "planet_languages", "languages"
  add_foreign_key "planet_languages", "planets"
  add_foreign_key "planet_languages", "users"
  add_foreign_key "planet_locations", "locations"
  add_foreign_key "planet_locations", "planets"
  add_foreign_key "planet_locations", "users"
  add_foreign_key "planet_nearby_planets", "planets"
  add_foreign_key "planet_nearby_planets", "users"
  add_foreign_key "planet_races", "planets"
  add_foreign_key "planet_races", "races"
  add_foreign_key "planet_races", "users"
  add_foreign_key "planet_religions", "planets"
  add_foreign_key "planet_religions", "religions"
  add_foreign_key "planet_religions", "users"
  add_foreign_key "planet_towns", "planets"
  add_foreign_key "planet_towns", "towns"
  add_foreign_key "planet_towns", "users"
  add_foreign_key "planets", "universes"
  add_foreign_key "planets", "users"
  add_foreign_key "promotions", "page_unlock_promo_codes"
  add_foreign_key "promotions", "users"
  add_foreign_key "raffle_entries", "users"
  add_foreign_key "referral_codes", "users"
  add_foreign_key "religion_deities", "deities"
  add_foreign_key "religion_deities", "religions"
  add_foreign_key "religion_deities", "users"
  add_foreign_key "schools", "universes"
  add_foreign_key "schools", "users"
  add_foreign_key "share_comments", "content_page_shares"
  add_foreign_key "share_comments", "users"
  add_foreign_key "sports", "universes"
  add_foreign_key "sports", "users"
  add_foreign_key "subscriptions", "billing_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "technologies", "universes"
  add_foreign_key "technologies", "users"
  add_foreign_key "technology_characters", "characters"
  add_foreign_key "technology_characters", "technologies"
  add_foreign_key "technology_characters", "users"
  add_foreign_key "technology_child_technologies", "technologies"
  add_foreign_key "technology_child_technologies", "users"
  add_foreign_key "technology_countries", "countries"
  add_foreign_key "technology_countries", "technologies"
  add_foreign_key "technology_countries", "users"
  add_foreign_key "technology_creatures", "creatures"
  add_foreign_key "technology_creatures", "technologies"
  add_foreign_key "technology_creatures", "users"
  add_foreign_key "technology_groups", "groups"
  add_foreign_key "technology_groups", "technologies"
  add_foreign_key "technology_groups", "users"
  add_foreign_key "technology_magics", "magics"
  add_foreign_key "technology_magics", "technologies"
  add_foreign_key "technology_magics", "users"
  add_foreign_key "technology_parent_technologies", "technologies"
  add_foreign_key "technology_parent_technologies", "users"
  add_foreign_key "technology_planets", "planets"
  add_foreign_key "technology_planets", "technologies"
  add_foreign_key "technology_planets", "users"
  add_foreign_key "technology_related_technologies", "technologies"
  add_foreign_key "technology_related_technologies", "users"
  add_foreign_key "technology_towns", "technologies"
  add_foreign_key "technology_towns", "towns"
  add_foreign_key "technology_towns", "users"
  add_foreign_key "thredded_messageboard_users", "thredded_messageboards", on_delete: :cascade
  add_foreign_key "thredded_messageboard_users", "thredded_user_details", on_delete: :cascade
  add_foreign_key "thredded_user_post_notifications", "thredded_posts", column: "post_id", on_delete: :cascade
  add_foreign_key "thredded_user_post_notifications", "users", on_delete: :cascade
  add_foreign_key "timeline_event_entities", "timeline_events"
  add_foreign_key "timeline_events", "timelines"
  add_foreign_key "timelines", "universes"
  add_foreign_key "timelines", "users"
  add_foreign_key "town_citizens", "towns"
  add_foreign_key "town_citizens", "users"
  add_foreign_key "town_countries", "countries"
  add_foreign_key "town_countries", "towns"
  add_foreign_key "town_countries", "users"
  add_foreign_key "town_creatures", "creatures"
  add_foreign_key "town_creatures", "towns"
  add_foreign_key "town_creatures", "users"
  add_foreign_key "town_floras", "floras"
  add_foreign_key "town_floras", "towns"
  add_foreign_key "town_floras", "users"
  add_foreign_key "town_groups", "groups"
  add_foreign_key "town_groups", "towns"
  add_foreign_key "town_groups", "users"
  add_foreign_key "town_languages", "languages"
  add_foreign_key "town_languages", "towns"
  add_foreign_key "town_languages", "users"
  add_foreign_key "town_nearby_landmarks", "towns"
  add_foreign_key "town_nearby_landmarks", "users"
  add_foreign_key "towns", "universes"
  add_foreign_key "towns", "users"
  add_foreign_key "traditions", "universes"
  add_foreign_key "traditions", "users"
  add_foreign_key "user_blockings", "users"
  add_foreign_key "user_content_type_activators", "users"
  add_foreign_key "user_followings", "users"
  add_foreign_key "vehicles", "universes"
  add_foreign_key "vehicles", "users"
  add_foreign_key "votes", "users"
  add_foreign_key "votes", "votables"
end
