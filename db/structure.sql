CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "username" varchar NOT NULL, "password" varchar NOT NULL, "created_at" datetime, "updated_at" datetime);
CREATE TABLE IF NOT EXISTS "siblingships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "sibling_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "fatherships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "father_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "motherships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "mother_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "best_friendships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "best_friend_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "marriages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "spouse_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "archenemyships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "archenemy_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "birthings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "character_id" integer, "birthplace_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "ownerships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "character_id" integer, "item_id" integer, "user_id" integer, "favorite" boolean, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "childrenships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "child_id" integer);
CREATE TABLE IF NOT EXISTS "largest_cities_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "location_id" integer, "largest_city_id" integer);
CREATE TABLE IF NOT EXISTS "notable_cities_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "location_id" integer, "notable_city_id" integer);
CREATE TABLE IF NOT EXISTS "capital_cities_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "location_id" integer, "capital_city_id" integer);
CREATE TABLE IF NOT EXISTS "location_leaderships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "location_id" integer, "leader_id" integer);
CREATE TABLE IF NOT EXISTS "original_ownerships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "item_id" integer, "original_owner_id" integer);
CREATE TABLE IF NOT EXISTS "current_ownerships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "item_id" integer, "current_owner_id" integer);
CREATE TABLE IF NOT EXISTS "maker_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "item_id" integer, "maker_id" integer);
CREATE TABLE IF NOT EXISTS "past_ownerships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "item_id" integer, "past_owner_id" integer);
CREATE TABLE IF NOT EXISTS "attributes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "attribute_field_id" integer, "entity_type" varchar NOT NULL, "entity_id" integer NOT NULL, "value" text, "privacy" varchar DEFAULT 'private' NOT NULL, "created_at" datetime, "updated_at" datetime, "deleted_at" datetime);
CREATE INDEX "index_attributes_on_user_id_and_entity_type_and_entity_id" ON "attributes" ("user_id", "entity_type", "entity_id");
CREATE TABLE IF NOT EXISTS "wildlifeships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "creature_id" integer, "habitat_id" integer);
CREATE TABLE IF NOT EXISTS "famous_figureships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "race_id" integer, "famous_figure_id" integer);
CREATE TABLE IF NOT EXISTS "raceships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "race_id" integer);
CREATE TABLE IF NOT EXISTS "religious_figureships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "religion_id" integer, "user_id" integer, "notable_figure_id" integer);
CREATE TABLE IF NOT EXISTS "deityships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "religion_id" integer, "deity_id" integer, "user_id" integer);
CREATE TABLE IF NOT EXISTS "religious_locationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "religion_id" integer, "practicing_location_id" integer, "user_id" integer);
CREATE TABLE IF NOT EXISTS "artifactships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "religion_id" integer, "artifact_id" integer, "user_id" integer);
CREATE TABLE IF NOT EXISTS "religious_raceships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "religion_id" integer, "race_id" integer, "user_id" integer);
CREATE TABLE IF NOT EXISTS "group_leaderships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "leader_id" integer);
CREATE TABLE IF NOT EXISTS "supergroupships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "supergroup_id" integer);
CREATE TABLE IF NOT EXISTS "subgroupships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "subgroup_id" integer);
CREATE TABLE IF NOT EXISTS "sistergroupships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "sistergroup_id" integer);
CREATE TABLE IF NOT EXISTS "group_allyships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "ally_id" integer);
CREATE TABLE IF NOT EXISTS "group_enemyships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "enemy_id" integer);
CREATE TABLE IF NOT EXISTS "group_rivalships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "rival_id" integer);
CREATE TABLE IF NOT EXISTS "group_clientships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "client_id" integer);
CREATE TABLE IF NOT EXISTS "group_supplierships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "supplier_id" integer);
CREATE TABLE IF NOT EXISTS "headquarterships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "headquarter_id" integer);
CREATE TABLE IF NOT EXISTS "officeships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "office_id" integer);
CREATE TABLE IF NOT EXISTS "group_equipmentships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "equipment_id" integer);
CREATE TABLE IF NOT EXISTS "key_itemships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "key_item_id" integer);
CREATE TABLE IF NOT EXISTS "magic_deityships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "magic_id" integer, "deity_id" integer);
CREATE TABLE IF NOT EXISTS "lingualisms" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "spoken_language_id" integer);
CREATE TABLE IF NOT EXISTS "scene_characterships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "scene_id" integer, "scene_character_id" integer);
CREATE TABLE IF NOT EXISTS "scene_locationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "scene_id" integer, "scene_location_id" integer);
CREATE TABLE IF NOT EXISTS "scene_itemships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "scene_id" integer, "scene_item_id" integer);
CREATE TABLE IF NOT EXISTS "group_memberships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "member_id" integer);
CREATE TABLE IF NOT EXISTS "group_locationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "group_id" integer, "location_id" integer);
CREATE TABLE IF NOT EXISTS "billing_plans" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "stripe_plan_id" varchar, "monthly_cents" integer, "available" boolean, "allows_core_content" boolean, "allows_extended_content" boolean, "allows_collective_content" boolean, "allows_collaboration" boolean, "universe_limit" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "bonus_bandwidth_kb" integer DEFAULT 0);
CREATE TABLE IF NOT EXISTS "subscriptions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "billing_plan_id" integer, "start_date" datetime, "end_date" datetime, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_933bdff476"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3cd83250c2"
FOREIGN KEY ("billing_plan_id")
  REFERENCES "billing_plans" ("id")
);
CREATE INDEX "index_subscriptions_on_user_id" ON "subscriptions" ("user_id");
CREATE INDEX "index_subscriptions_on_billing_plan_id" ON "subscriptions" ("billing_plan_id");
CREATE TABLE IF NOT EXISTS "image_uploads" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "privacy" varchar, "user_id" integer, "content_type" varchar, "content_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "src_file_name" varchar, "src_content_type" varchar, "src_file_size" bigint, "src_updated_at" datetime, CONSTRAINT "fk_rails_aafdb1fa1c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_image_uploads_on_user_id" ON "image_uploads" ("user_id");
CREATE TABLE IF NOT EXISTS "creature_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "creature_id" integer, "related_creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "location_languageships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "location_id" integer, "language_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "referral_codes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "code" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a636218385"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_referral_codes_on_user_id" ON "referral_codes" ("user_id");
CREATE TABLE IF NOT EXISTS "referrals" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "referrer_id" integer, "referred_id" integer, "associated_code_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "votables" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "description" varchar, "icon" varchar, "link" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "votes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "votable_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_c9b3bef597"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_d51272a189"
FOREIGN KEY ("votable_id")
  REFERENCES "votables" ("id")
);
CREATE INDEX "index_votes_on_user_id" ON "votes" ("user_id");
CREATE INDEX "index_votes_on_votable_id" ON "votes" ("votable_id");
CREATE TABLE IF NOT EXISTS "raffle_entries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b72d29a6a7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_raffle_entries_on_user_id" ON "raffle_entries" ("user_id");
CREATE TABLE IF NOT EXISTS "content_change_events" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "changed_fields" text, "content_id" integer, "content_type" varchar, "action" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_cef03de1b7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_content_change_events_on_user_id" ON "content_change_events" ("user_id");
CREATE TABLE IF NOT EXISTS "friendly_id_slugs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "slug" varchar NOT NULL, "sluggable_id" integer NOT NULL, "sluggable_type" varchar(50), "scope" varchar, "created_at" datetime);
CREATE INDEX "index_friendly_id_slugs_on_sluggable_id" ON "friendly_id_slugs" ("sluggable_id");
CREATE INDEX "index_friendly_id_slugs_on_slug_and_sluggable_type" ON "friendly_id_slugs" ("slug", "sluggable_type");
CREATE UNIQUE INDEX "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope" ON "friendly_id_slugs" ("slug", "sluggable_type", "scope");
CREATE INDEX "index_friendly_id_slugs_on_sluggable_type" ON "friendly_id_slugs" ("sluggable_type");
CREATE TABLE IF NOT EXISTS "thredded_private_users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "private_topic_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_thredded_private_users_on_private_topic_id" ON "thredded_private_users" ("private_topic_id");
CREATE INDEX "index_thredded_private_users_on_user_id" ON "thredded_private_users" ("user_id");
CREATE TABLE IF NOT EXISTS "thredded_topic_categories" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "topic_id" integer NOT NULL, "category_id" integer NOT NULL);
CREATE INDEX "index_thredded_topic_categories_on_category_id" ON "thredded_topic_categories" ("category_id");
CREATE INDEX "index_thredded_topic_categories_on_topic_id" ON "thredded_topic_categories" ("topic_id");
CREATE TABLE IF NOT EXISTS "thredded_messageboard_users" ("id" integer NOT NULL PRIMARY KEY, "thredded_user_detail_id" integer NOT NULL, "thredded_messageboard_id" integer NOT NULL, "last_seen_at" datetime NOT NULL, CONSTRAINT "fk_rails_06e42c62f5"
FOREIGN KEY ("thredded_user_detail_id")
  REFERENCES "thredded_user_details" ("id")
 ON DELETE CASCADE, CONSTRAINT "fk_rails_966803d714"
FOREIGN KEY ("thredded_messageboard_id")
  REFERENCES "thredded_messageboards" ("id")
 ON DELETE CASCADE);
CREATE INDEX "index_thredded_messageboard_users_for_recently_active" ON "thredded_messageboard_users" ("thredded_messageboard_id", "last_seen_at");
CREATE TABLE IF NOT EXISTS "thredded_user_preferences" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "follow_topics_on_mention" boolean DEFAULT 1 NOT NULL, "auto_follow_topics" boolean DEFAULT 0 NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "thredded_user_messageboard_preferences" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "messageboard_id" integer NOT NULL, "follow_topics_on_mention" boolean DEFAULT 1 NOT NULL, "auto_follow_topics" boolean DEFAULT 0 NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "thredded_user_messageboard_preferences_user_id_messageboard_id" ON "thredded_user_messageboard_preferences" ("user_id", "messageboard_id");
CREATE TABLE IF NOT EXISTS "thredded_messageboard_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "position" integer NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "thredded_user_topic_follows" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "topic_id" integer NOT NULL, "created_at" datetime NOT NULL, "reason" integer(1));
CREATE UNIQUE INDEX "thredded_user_topic_follows_user_topic" ON "thredded_user_topic_follows" ("user_id", "topic_id");
CREATE TABLE IF NOT EXISTS "thredded_post_moderation_records" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "post_id" integer, "messageboard_id" integer, "post_content" text(65535), "post_user_id" integer, "post_user_name" text, "moderator_id" integer, "moderation_state" integer NOT NULL, "previous_moderation_state" integer NOT NULL, "created_at" datetime NOT NULL);
CREATE INDEX "index_thredded_moderation_records_for_display" ON "thredded_post_moderation_records" ("messageboard_id", "created_at" DESC);
CREATE TABLE IF NOT EXISTS "thredded_notifications_for_private_topics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "notifier_key" varchar(90) NOT NULL, "enabled" boolean DEFAULT 1 NOT NULL);
CREATE UNIQUE INDEX "thredded_notifications_for_private_topics_unique" ON "thredded_notifications_for_private_topics" ("user_id", "notifier_key");
CREATE TABLE IF NOT EXISTS "thredded_notifications_for_followed_topics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "notifier_key" varchar(90) NOT NULL, "enabled" boolean DEFAULT 1 NOT NULL);
CREATE UNIQUE INDEX "thredded_notifications_for_followed_topics_unique" ON "thredded_notifications_for_followed_topics" ("user_id", "notifier_key");
CREATE TABLE IF NOT EXISTS "thredded_messageboard_notifications_for_followed_topics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "messageboard_id" integer NOT NULL, "notifier_key" varchar(90) NOT NULL, "enabled" boolean DEFAULT 1 NOT NULL);
CREATE UNIQUE INDEX "thredded_messageboard_notifications_for_followed_topics_unique" ON "thredded_messageboard_notifications_for_followed_topics" ("user_id", "messageboard_id", "notifier_key");
CREATE TABLE IF NOT EXISTS "thredded_user_post_notifications" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer NOT NULL, "post_id" integer NOT NULL, "notified_at" datetime NOT NULL, CONSTRAINT "fk_rails_5908eec802"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
 ON DELETE CASCADE, CONSTRAINT "fk_rails_364d7e370a"
FOREIGN KEY ("post_id")
  REFERENCES "thredded_posts" ("id")
 ON DELETE CASCADE);
CREATE INDEX "index_thredded_user_post_notifications_on_post_id" ON "thredded_user_post_notifications" ("post_id");
CREATE UNIQUE INDEX "index_thredded_user_post_notifications_on_user_id_and_post_id" ON "thredded_user_post_notifications" ("user_id", "post_id");
CREATE TABLE IF NOT EXISTS "flora_magical_effects" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "flora_id" integer, "magic_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "flora_locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "flora_id" integer, "location_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "flora_eaten_bies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "flora_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "flora_relationships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "flora_id" integer, "related_flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_thredded_user_preferences_on_user_id" ON "thredded_user_preferences" ("user_id");
CREATE TABLE IF NOT EXISTS "contributors" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "universe_id" integer, "email" varchar, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_5cf276f436"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_75adfa0433"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_contributors_on_universe_id" ON "contributors" ("universe_id");
CREATE INDEX "index_contributors_on_user_id" ON "contributors" ("user_id");
CREATE TABLE IF NOT EXISTS "delayed_jobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "priority" integer DEFAULT 0 NOT NULL, "attempts" integer DEFAULT 0 NOT NULL, "handler" text NOT NULL, "last_error" text, "run_at" datetime, "locked_at" datetime, "failed_at" datetime, "locked_by" varchar, "queue" varchar, "created_at" datetime, "updated_at" datetime);
CREATE INDEX "delayed_jobs_priority" ON "delayed_jobs" ("priority", "run_at");
CREATE TABLE IF NOT EXISTS "character_love_interests" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "love_interest_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_ff29554037"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_f8eedaa100"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
);
CREATE INDEX "index_character_love_interests_on_user_id" ON "character_love_interests" ("user_id");
CREATE INDEX "index_character_love_interests_on_character_id" ON "character_love_interests" ("character_id");
CREATE TABLE IF NOT EXISTS "user_content_type_activators" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "content_type" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a281e3bbd3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_user_content_type_activators_on_user_id" ON "user_content_type_activators" ("user_id");
CREATE TABLE IF NOT EXISTS "country_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "town_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_e295facadd"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_cd5ecbca0b"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_93d5b570e3"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
);
CREATE INDEX "index_country_towns_on_user_id" ON "country_towns" ("user_id");
CREATE INDEX "index_country_towns_on_country_id" ON "country_towns" ("country_id");
CREATE INDEX "index_country_towns_on_town_id" ON "country_towns" ("town_id");
CREATE TABLE IF NOT EXISTS "country_locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "location_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_de8ed2bf0d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_2c5eaaf4e6"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_68932cea82"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
);
CREATE INDEX "index_country_locations_on_user_id" ON "country_locations" ("user_id");
CREATE INDEX "index_country_locations_on_country_id" ON "country_locations" ("country_id");
CREATE INDEX "index_country_locations_on_location_id" ON "country_locations" ("location_id");
CREATE TABLE IF NOT EXISTS "country_languages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "language_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_1710730113"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_512239a8b1"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_52894a2633"
FOREIGN KEY ("language_id")
  REFERENCES "languages" ("id")
);
CREATE INDEX "index_country_languages_on_user_id" ON "country_languages" ("user_id");
CREATE INDEX "index_country_languages_on_country_id" ON "country_languages" ("country_id");
CREATE INDEX "index_country_languages_on_language_id" ON "country_languages" ("language_id");
CREATE TABLE IF NOT EXISTS "country_religions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "religion_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_ff041e28f9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_53b8ddbaec"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_7e9edf6226"
FOREIGN KEY ("religion_id")
  REFERENCES "religions" ("id")
);
CREATE INDEX "index_country_religions_on_user_id" ON "country_religions" ("user_id");
CREATE INDEX "index_country_religions_on_country_id" ON "country_religions" ("country_id");
CREATE INDEX "index_country_religions_on_religion_id" ON "country_religions" ("religion_id");
CREATE TABLE IF NOT EXISTS "country_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "landmark_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_2b94ac124c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_00318cb492"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_2df2bf3679"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
);
CREATE INDEX "index_country_landmarks_on_user_id" ON "country_landmarks" ("user_id");
CREATE INDEX "index_country_landmarks_on_country_id" ON "country_landmarks" ("country_id");
CREATE INDEX "index_country_landmarks_on_landmark_id" ON "country_landmarks" ("landmark_id");
CREATE TABLE IF NOT EXISTS "country_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_47834eda23"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ec5ea364f7"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_cbd46d65a1"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_country_creatures_on_user_id" ON "country_creatures" ("user_id");
CREATE INDEX "index_country_creatures_on_country_id" ON "country_creatures" ("country_id");
CREATE INDEX "index_country_creatures_on_creature_id" ON "country_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "country_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "country_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_c31dc3ac40"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_271bb94de2"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_f32e341576"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_country_floras_on_user_id" ON "country_floras" ("user_id");
CREATE INDEX "index_country_floras_on_country_id" ON "country_floras" ("country_id");
CREATE INDEX "index_country_floras_on_flora_id" ON "country_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "town_citizens" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "citizen_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9357a95a09"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_40bff2caf8"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
);
CREATE INDEX "index_town_citizens_on_user_id" ON "town_citizens" ("user_id");
CREATE INDEX "index_town_citizens_on_town_id" ON "town_citizens" ("town_id");
CREATE TABLE IF NOT EXISTS "town_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_85267b3645"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_785937ca10"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_966e50d832"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_town_floras_on_user_id" ON "town_floras" ("user_id");
CREATE INDEX "index_town_floras_on_town_id" ON "town_floras" ("town_id");
CREATE INDEX "index_town_floras_on_flora_id" ON "town_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "town_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_ad1f07e86d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_093531ac56"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_e225c55725"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_town_creatures_on_user_id" ON "town_creatures" ("user_id");
CREATE INDEX "index_town_creatures_on_town_id" ON "town_creatures" ("town_id");
CREATE INDEX "index_town_creatures_on_creature_id" ON "town_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "town_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "group_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_76a966755f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_10ad90c4a1"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_b2daa0ee0b"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
);
CREATE INDEX "index_town_groups_on_user_id" ON "town_groups" ("user_id");
CREATE INDEX "index_town_groups_on_town_id" ON "town_groups" ("town_id");
CREATE INDEX "index_town_groups_on_group_id" ON "town_groups" ("group_id");
CREATE TABLE IF NOT EXISTS "town_languages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "language_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_93e2a04270"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_7cf18fbdfe"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_e8a5d9aed7"
FOREIGN KEY ("language_id")
  REFERENCES "languages" ("id")
);
CREATE INDEX "index_town_languages_on_user_id" ON "town_languages" ("user_id");
CREATE INDEX "index_town_languages_on_town_id" ON "town_languages" ("town_id");
CREATE INDEX "index_town_languages_on_language_id" ON "town_languages" ("language_id");
CREATE TABLE IF NOT EXISTS "town_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "country_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9628760141"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_079ace43b3"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_d8b5e1d4fb"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
);
CREATE INDEX "index_town_countries_on_user_id" ON "town_countries" ("user_id");
CREATE INDEX "index_town_countries_on_town_id" ON "town_countries" ("town_id");
CREATE INDEX "index_town_countries_on_country_id" ON "town_countries" ("country_id");
CREATE TABLE IF NOT EXISTS "town_nearby_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "town_id" integer, "nearby_landmark_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_eb35caf879"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_85e20de879"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
);
CREATE INDEX "index_town_nearby_landmarks_on_user_id" ON "town_nearby_landmarks" ("user_id");
CREATE INDEX "index_town_nearby_landmarks_on_town_id" ON "town_nearby_landmarks" ("town_id");
CREATE TABLE IF NOT EXISTS "landmark_nearby_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "landmark_id" integer, "nearby_town_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_e806d89196"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_85a57b77d8"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
);
CREATE INDEX "index_landmark_nearby_towns_on_user_id" ON "landmark_nearby_towns" ("user_id");
CREATE INDEX "index_landmark_nearby_towns_on_landmark_id" ON "landmark_nearby_towns" ("landmark_id");
CREATE TABLE IF NOT EXISTS "landmark_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "landmark_id" integer, "country_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_630b319a8e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_20d46a1626"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
, CONSTRAINT "fk_rails_4c63abfe98"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
);
CREATE INDEX "index_landmark_countries_on_user_id" ON "landmark_countries" ("user_id");
CREATE INDEX "index_landmark_countries_on_landmark_id" ON "landmark_countries" ("landmark_id");
CREATE INDEX "index_landmark_countries_on_country_id" ON "landmark_countries" ("country_id");
CREATE TABLE IF NOT EXISTS "landmark_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "landmark_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_906cddac0b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_5e9c0a920a"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
, CONSTRAINT "fk_rails_8b47c0eeda"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_landmark_floras_on_user_id" ON "landmark_floras" ("user_id");
CREATE INDEX "index_landmark_floras_on_landmark_id" ON "landmark_floras" ("landmark_id");
CREATE INDEX "index_landmark_floras_on_flora_id" ON "landmark_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "landmark_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "landmark_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_1a8b3a567e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_fb4ef20dba"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
, CONSTRAINT "fk_rails_ed30ed1f56"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_landmark_creatures_on_user_id" ON "landmark_creatures" ("user_id");
CREATE INDEX "index_landmark_creatures_on_landmark_id" ON "landmark_creatures" ("landmark_id");
CREATE INDEX "index_landmark_creatures_on_creature_id" ON "landmark_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "stripe_event_logs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "event_id" varchar, "event_type" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_thredded_messageboard_users_primary" ON "thredded_messageboard_users" ("thredded_messageboard_id", "thredded_user_detail_id");
CREATE TABLE IF NOT EXISTS "thredded_categories" ("id" integer NOT NULL PRIMARY KEY, "messageboard_id" integer NOT NULL, "name" text NOT NULL, "description" text DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "slug" text NOT NULL);
CREATE INDEX "index_thredded_categories_on_messageboard_id" ON "thredded_categories" ("messageboard_id");
CREATE INDEX "thredded_categories_name_ci" ON "thredded_categories" ("name");
CREATE UNIQUE INDEX "index_thredded_categories_on_messageboard_id_and_slug" ON "thredded_categories" ("messageboard_id", "slug");
CREATE TABLE IF NOT EXISTS "thredded_messageboards" ("id" integer NOT NULL PRIMARY KEY, "name" text NOT NULL, "slug" text DEFAULT NULL, "description" text DEFAULT NULL, "topics_count" integer DEFAULT 0, "posts_count" integer DEFAULT 0, "position" integer NOT NULL, "last_topic_id" integer DEFAULT NULL, "messageboard_group_id" integer DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "locked" boolean DEFAULT 0 NOT NULL);
CREATE INDEX "index_thredded_messageboards_on_messageboard_group_id" ON "thredded_messageboards" ("messageboard_group_id");
CREATE UNIQUE INDEX "index_thredded_messageboards_on_slug" ON "thredded_messageboards" ("slug");
CREATE TABLE IF NOT EXISTS "thredded_private_topics" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "last_user_id" integer DEFAULT NULL, "title" text NOT NULL, "slug" text NOT NULL, "posts_count" integer DEFAULT 0, "hash_id" varchar(20) NOT NULL, "last_post_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_thredded_private_topics_on_hash_id" ON "thredded_private_topics" ("hash_id");
CREATE UNIQUE INDEX "index_thredded_private_topics_on_slug" ON "thredded_private_topics" ("slug");
CREATE TABLE IF NOT EXISTS "thredded_topics" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "last_user_id" integer DEFAULT NULL, "title" text NOT NULL, "slug" text NOT NULL, "messageboard_id" integer NOT NULL, "posts_count" integer DEFAULT 0 NOT NULL, "sticky" boolean DEFAULT 0 NOT NULL, "locked" boolean DEFAULT 0 NOT NULL, "hash_id" varchar(20) NOT NULL, "moderation_state" integer NOT NULL, "last_post_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime);
CREATE INDEX "index_thredded_topics_for_display" ON "thredded_topics" ("moderation_state", "sticky", "updated_at");
CREATE INDEX "index_thredded_topics_on_hash_id" ON "thredded_topics" ("hash_id");
CREATE INDEX "index_thredded_topics_on_messageboard_id" ON "thredded_topics" ("messageboard_id");
CREATE INDEX "index_thredded_topics_on_user_id" ON "thredded_topics" ("user_id");
CREATE UNIQUE INDEX "index_thredded_topics_on_slug" ON "thredded_topics" ("slug");
CREATE TABLE IF NOT EXISTS "thredded_private_posts" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "content" text(65535) DEFAULT NULL, "postable_id" integer NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "thredded_user_private_topic_read_states" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer NOT NULL, "postable_id" integer NOT NULL, "read_at" datetime NOT NULL, "unread_posts_count" integer DEFAULT 0 NOT NULL, "read_posts_count" integer DEFAULT 0 NOT NULL);
CREATE UNIQUE INDEX "thredded_user_private_topic_read_states_user_postable" ON "thredded_user_private_topic_read_states" ("user_id", "postable_id");
CREATE INDEX "index_thredded_topics_on_last_post_at" ON "thredded_topics" ("last_post_at");
CREATE INDEX "index_thredded_private_topics_on_last_post_at" ON "thredded_private_topics" ("last_post_at");
CREATE INDEX "index_thredded_private_posts_on_postable_id_and_created_at" ON "thredded_private_posts" ("postable_id", "created_at");
CREATE INDEX "index_content_change_events_on_content_id_and_content_type" ON "content_change_events" ("content_id", "content_type");
CREATE INDEX "index_image_uploads_on_content_type_and_content_id" ON "image_uploads" ("content_type", "content_id");
CREATE TABLE IF NOT EXISTS "planet_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "country_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_4b0a8cfdbe"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_cc7262669e"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_3fd1f5a94e"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
);
CREATE INDEX "index_planet_countries_on_user_id" ON "planet_countries" ("user_id");
CREATE INDEX "index_planet_countries_on_planet_id" ON "planet_countries" ("planet_id");
CREATE INDEX "index_planet_countries_on_country_id" ON "planet_countries" ("country_id");
CREATE TABLE IF NOT EXISTS "planet_locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "location_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_709ec1ec69"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_83244627a4"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_4a4c6b868c"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
);
CREATE INDEX "index_planet_locations_on_user_id" ON "planet_locations" ("user_id");
CREATE INDEX "index_planet_locations_on_planet_id" ON "planet_locations" ("planet_id");
CREATE INDEX "index_planet_locations_on_location_id" ON "planet_locations" ("location_id");
CREATE TABLE IF NOT EXISTS "planet_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "landmark_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_16d59014db"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_91fec1c73a"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_bc0756069b"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
);
CREATE INDEX "index_planet_landmarks_on_user_id" ON "planet_landmarks" ("user_id");
CREATE INDEX "index_planet_landmarks_on_planet_id" ON "planet_landmarks" ("planet_id");
CREATE INDEX "index_planet_landmarks_on_landmark_id" ON "planet_landmarks" ("landmark_id");
CREATE TABLE IF NOT EXISTS "planet_races" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "race_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_e4326387a1"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_13b750add5"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_7682ef94c3"
FOREIGN KEY ("race_id")
  REFERENCES "races" ("id")
);
CREATE INDEX "index_planet_races_on_user_id" ON "planet_races" ("user_id");
CREATE INDEX "index_planet_races_on_planet_id" ON "planet_races" ("planet_id");
CREATE INDEX "index_planet_races_on_race_id" ON "planet_races" ("race_id");
CREATE TABLE IF NOT EXISTS "planet_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_38266689fd"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_0097966fec"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_660a8e59b7"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_planet_floras_on_user_id" ON "planet_floras" ("user_id");
CREATE INDEX "index_planet_floras_on_planet_id" ON "planet_floras" ("planet_id");
CREATE INDEX "index_planet_floras_on_flora_id" ON "planet_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "planet_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_87f546669e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_9459d1f2ea"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_0b7e25f240"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_planet_creatures_on_user_id" ON "planet_creatures" ("user_id");
CREATE INDEX "index_planet_creatures_on_planet_id" ON "planet_creatures" ("planet_id");
CREATE INDEX "index_planet_creatures_on_creature_id" ON "planet_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "planet_religions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "religion_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_dfd8a3e817"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_16b5bd0371"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_7fdaac3625"
FOREIGN KEY ("religion_id")
  REFERENCES "religions" ("id")
);
CREATE INDEX "index_planet_religions_on_user_id" ON "planet_religions" ("user_id");
CREATE INDEX "index_planet_religions_on_planet_id" ON "planet_religions" ("planet_id");
CREATE INDEX "index_planet_religions_on_religion_id" ON "planet_religions" ("religion_id");
CREATE TABLE IF NOT EXISTS "planet_deities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "deity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_f35621c25d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_c3c3681b6d"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_6811950280"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_planet_deities_on_user_id" ON "planet_deities" ("user_id");
CREATE INDEX "index_planet_deities_on_planet_id" ON "planet_deities" ("planet_id");
CREATE INDEX "index_planet_deities_on_deity_id" ON "planet_deities" ("deity_id");
CREATE TABLE IF NOT EXISTS "planet_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "group_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_d101f01cc6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_560d8dc301"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_e271d0e90b"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
);
CREATE INDEX "index_planet_groups_on_user_id" ON "planet_groups" ("user_id");
CREATE INDEX "index_planet_groups_on_planet_id" ON "planet_groups" ("planet_id");
CREATE INDEX "index_planet_groups_on_group_id" ON "planet_groups" ("group_id");
CREATE TABLE IF NOT EXISTS "planet_languages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "language_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_2021c47835"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_9de694bc46"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_8b749720ba"
FOREIGN KEY ("language_id")
  REFERENCES "languages" ("id")
);
CREATE INDEX "index_planet_languages_on_user_id" ON "planet_languages" ("user_id");
CREATE INDEX "index_planet_languages_on_planet_id" ON "planet_languages" ("planet_id");
CREATE INDEX "index_planet_languages_on_language_id" ON "planet_languages" ("language_id");
CREATE TABLE IF NOT EXISTS "planet_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "town_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_5c06103aab"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_773d2ca583"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_4d9e3111de"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
);
CREATE INDEX "index_planet_towns_on_user_id" ON "planet_towns" ("user_id");
CREATE INDEX "index_planet_towns_on_planet_id" ON "planet_towns" ("planet_id");
CREATE INDEX "index_planet_towns_on_town_id" ON "planet_towns" ("town_id");
CREATE TABLE IF NOT EXISTS "planet_nearby_planets" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "planet_id" integer, "nearby_planet_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9d18e8d3ba"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_697cd3c08a"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
);
CREATE INDEX "index_planet_nearby_planets_on_user_id" ON "planet_nearby_planets" ("user_id");
CREATE INDEX "index_planet_nearby_planets_on_planet_id" ON "planet_nearby_planets" ("planet_id");
CREATE TABLE IF NOT EXISTS "technology_characters" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "character_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9d6418053f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_5c6baa3fe2"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_d84e0583a4"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
);
CREATE INDEX "index_technology_characters_on_user_id" ON "technology_characters" ("user_id");
CREATE INDEX "index_technology_characters_on_technology_id" ON "technology_characters" ("technology_id");
CREATE INDEX "index_technology_characters_on_character_id" ON "technology_characters" ("character_id");
CREATE TABLE IF NOT EXISTS "technology_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "town_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_5c58657e1d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_0684f54677"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_8f891bd2f0"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
);
CREATE INDEX "index_technology_towns_on_user_id" ON "technology_towns" ("user_id");
CREATE INDEX "index_technology_towns_on_technology_id" ON "technology_towns" ("technology_id");
CREATE INDEX "index_technology_towns_on_town_id" ON "technology_towns" ("town_id");
CREATE TABLE IF NOT EXISTS "technology_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "country_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_2b1bf28f5d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_88281393d9"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_dd9c945bde"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
);
CREATE INDEX "index_technology_countries_on_user_id" ON "technology_countries" ("user_id");
CREATE INDEX "index_technology_countries_on_technology_id" ON "technology_countries" ("technology_id");
CREATE INDEX "index_technology_countries_on_country_id" ON "technology_countries" ("country_id");
CREATE TABLE IF NOT EXISTS "technology_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "group_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_670245ea20"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_10be78ad8b"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_2a46f510ac"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
);
CREATE INDEX "index_technology_groups_on_user_id" ON "technology_groups" ("user_id");
CREATE INDEX "index_technology_groups_on_technology_id" ON "technology_groups" ("technology_id");
CREATE INDEX "index_technology_groups_on_group_id" ON "technology_groups" ("group_id");
CREATE TABLE IF NOT EXISTS "technology_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9ddc7bd04c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_dba457a3e9"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_8782b69cf2"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_technology_creatures_on_user_id" ON "technology_creatures" ("user_id");
CREATE INDEX "index_technology_creatures_on_technology_id" ON "technology_creatures" ("technology_id");
CREATE INDEX "index_technology_creatures_on_creature_id" ON "technology_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "technology_planets" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "planet_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b1ac1a4b21"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_070dd312ae"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_b958705950"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
);
CREATE INDEX "index_technology_planets_on_user_id" ON "technology_planets" ("user_id");
CREATE INDEX "index_technology_planets_on_technology_id" ON "technology_planets" ("technology_id");
CREATE INDEX "index_technology_planets_on_planet_id" ON "technology_planets" ("planet_id");
CREATE TABLE IF NOT EXISTS "technology_magics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "magic_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_0e20633e3c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ca64bef4e0"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_949bcab7e9"
FOREIGN KEY ("magic_id")
  REFERENCES "magics" ("id")
);
CREATE INDEX "index_technology_magics_on_user_id" ON "technology_magics" ("user_id");
CREATE INDEX "index_technology_magics_on_technology_id" ON "technology_magics" ("technology_id");
CREATE INDEX "index_technology_magics_on_magic_id" ON "technology_magics" ("magic_id");
CREATE TABLE IF NOT EXISTS "technology_parent_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "parent_technology_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_00bd3abc80"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3e77a3ab03"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
);
CREATE INDEX "index_technology_parent_technologies_on_user_id" ON "technology_parent_technologies" ("user_id");
CREATE INDEX "index_technology_parent_technologies_on_technology_id" ON "technology_parent_technologies" ("technology_id");
CREATE TABLE IF NOT EXISTS "technology_child_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "child_technology_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_d71699382b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_25a8c33372"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
);
CREATE INDEX "index_technology_child_technologies_on_user_id" ON "technology_child_technologies" ("user_id");
CREATE INDEX "index_technology_child_technologies_on_technology_id" ON "technology_child_technologies" ("technology_id");
CREATE TABLE IF NOT EXISTS "technology_related_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "technology_id" integer, "related_technology_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_fefb4182fe"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_5fa34a7560"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
);
CREATE INDEX "index_technology_related_technologies_on_user_id" ON "technology_related_technologies" ("user_id");
CREATE INDEX "index_technology_related_technologies_on_technology_id" ON "technology_related_technologies" ("technology_id");
CREATE TABLE IF NOT EXISTS "deity_character_parents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "character_parent_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_bfb76d8df6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a4ab309173"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_character_parents_on_user_id" ON "deity_character_parents" ("user_id");
CREATE INDEX "index_deity_character_parents_on_deity_id" ON "deity_character_parents" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_character_partners" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "character_partner_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_732b97fd4e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_cd7b28ee91"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_character_partners_on_user_id" ON "deity_character_partners" ("user_id");
CREATE INDEX "index_deity_character_partners_on_deity_id" ON "deity_character_partners" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_character_children" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "character_child_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_6af6f3876f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_144415d98c"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_character_children_on_user_id" ON "deity_character_children" ("user_id");
CREATE INDEX "index_deity_character_children_on_deity_id" ON "deity_character_children" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_deity_parents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "deity_parent_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_bb32bf74e8"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_e765ded7c0"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_deity_parents_on_user_id" ON "deity_deity_parents" ("user_id");
CREATE INDEX "index_deity_deity_parents_on_deity_id" ON "deity_deity_parents" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_deity_partners" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "deity_partner_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_d33a59a20f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_d09301a717"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_deity_partners_on_user_id" ON "deity_deity_partners" ("user_id");
CREATE INDEX "index_deity_deity_partners_on_deity_id" ON "deity_deity_partners" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_deity_children" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "deity_child_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_457857aa78"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_6c51f2aa0b"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_deity_children_on_user_id" ON "deity_deity_children" ("user_id");
CREATE INDEX "index_deity_deity_children_on_deity_id" ON "deity_deity_children" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_849bf97707"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_36d2d6f2ea"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_66834cfb3b"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_deity_creatures_on_user_id" ON "deity_creatures" ("user_id");
CREATE INDEX "index_deity_creatures_on_deity_id" ON "deity_creatures" ("deity_id");
CREATE INDEX "index_deity_creatures_on_creature_id" ON "deity_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "deity_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_46b2407576"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a2488bc582"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_8f8ba7eaa0"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_deity_floras_on_user_id" ON "deity_floras" ("user_id");
CREATE INDEX "index_deity_floras_on_deity_id" ON "deity_floras" ("deity_id");
CREATE INDEX "index_deity_floras_on_flora_id" ON "deity_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "deity_religions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "religion_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_18b09e08ff"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_c1a9aae3dc"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_b5860d70f0"
FOREIGN KEY ("religion_id")
  REFERENCES "religions" ("id")
);
CREATE INDEX "index_deity_religions_on_user_id" ON "deity_religions" ("user_id");
CREATE INDEX "index_deity_religions_on_deity_id" ON "deity_religions" ("deity_id");
CREATE INDEX "index_deity_religions_on_religion_id" ON "deity_religions" ("religion_id");
CREATE TABLE IF NOT EXISTS "deity_relics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "relic_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_79f6a4201f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_263939338d"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_relics_on_user_id" ON "deity_relics" ("user_id");
CREATE INDEX "index_deity_relics_on_deity_id" ON "deity_relics" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_abilities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "ability_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_29a76fef54"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a782c7d45a"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_abilities_on_user_id" ON "deity_abilities" ("user_id");
CREATE INDEX "index_deity_abilities_on_deity_id" ON "deity_abilities" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_related_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "related_town_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_00220cc8c9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_46ef22ab54"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_related_towns_on_user_id" ON "deity_related_towns" ("user_id");
CREATE INDEX "index_deity_related_towns_on_deity_id" ON "deity_related_towns" ("deity_id");
CREATE TABLE IF NOT EXISTS "deity_related_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "deity_id" integer, "related_landmark_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_3bd0408898"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_7ca9b9cc86"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_deity_related_landmarks_on_user_id" ON "deity_related_landmarks" ("user_id");
CREATE INDEX "index_deity_related_landmarks_on_deity_id" ON "deity_related_landmarks" ("deity_id");
CREATE TABLE IF NOT EXISTS "government_leaders" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "leader_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_66e8529ca6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3af3827b37"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
);
CREATE INDEX "index_government_leaders_on_user_id" ON "government_leaders" ("user_id");
CREATE INDEX "index_government_leaders_on_government_id" ON "government_leaders" ("government_id");
CREATE TABLE IF NOT EXISTS "government_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "group_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_595a5e2d38"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a4c4a2ac66"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_5a26171ce0"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
);
CREATE INDEX "index_government_groups_on_user_id" ON "government_groups" ("user_id");
CREATE INDEX "index_government_groups_on_government_id" ON "government_groups" ("government_id");
CREATE INDEX "index_government_groups_on_group_id" ON "government_groups" ("group_id");
CREATE TABLE IF NOT EXISTS "government_political_figures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "political_figure_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_fd542e857a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_1bd3a314e6"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
);
CREATE INDEX "index_government_political_figures_on_user_id" ON "government_political_figures" ("user_id");
CREATE INDEX "index_government_political_figures_on_government_id" ON "government_political_figures" ("government_id");
CREATE TABLE IF NOT EXISTS "government_items" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "item_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_de3379066f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_f3bed37b21"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_6b66400484"
FOREIGN KEY ("item_id")
  REFERENCES "items" ("id")
);
CREATE INDEX "index_government_items_on_user_id" ON "government_items" ("user_id");
CREATE INDEX "index_government_items_on_government_id" ON "government_items" ("government_id");
CREATE INDEX "index_government_items_on_item_id" ON "government_items" ("item_id");
CREATE TABLE IF NOT EXISTS "government_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "technology_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_21ba6952ad"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_b04b89affe"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_9be6ddaa75"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
);
CREATE INDEX "index_government_technologies_on_user_id" ON "government_technologies" ("user_id");
CREATE INDEX "index_government_technologies_on_government_id" ON "government_technologies" ("government_id");
CREATE INDEX "index_government_technologies_on_technology_id" ON "government_technologies" ("technology_id");
CREATE TABLE IF NOT EXISTS "government_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "government_id" integer, "creature_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_6d47dde360"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_04dad67c1d"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_851563604e"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
);
CREATE INDEX "index_government_creatures_on_user_id" ON "government_creatures" ("user_id");
CREATE INDEX "index_government_creatures_on_government_id" ON "government_creatures" ("government_id");
CREATE INDEX "index_government_creatures_on_creature_id" ON "government_creatures" ("creature_id");
CREATE TABLE IF NOT EXISTS "character_items" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "item_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_2e13879efb"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_c1dafae0c9"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_ffe3de2639"
FOREIGN KEY ("item_id")
  REFERENCES "items" ("id")
);
CREATE INDEX "index_character_items_on_user_id" ON "character_items" ("user_id");
CREATE INDEX "index_character_items_on_character_id" ON "character_items" ("character_id");
CREATE INDEX "index_character_items_on_item_id" ON "character_items" ("item_id");
CREATE TABLE IF NOT EXISTS "character_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "technology_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_536ae0fffb"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_70d849e91a"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_99c7e69322"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
);
CREATE INDEX "index_character_technologies_on_user_id" ON "character_technologies" ("user_id");
CREATE INDEX "index_character_technologies_on_character_id" ON "character_technologies" ("character_id");
CREATE INDEX "index_character_technologies_on_technology_id" ON "character_technologies" ("technology_id");
CREATE TABLE IF NOT EXISTS "character_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "flora_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_3759f5cab1"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_4d19e7db6b"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_695be098be"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
);
CREATE INDEX "index_character_floras_on_user_id" ON "character_floras" ("user_id");
CREATE INDEX "index_character_floras_on_character_id" ON "character_floras" ("character_id");
CREATE INDEX "index_character_floras_on_flora_id" ON "character_floras" ("flora_id");
CREATE TABLE IF NOT EXISTS "character_friends" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "friend_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a10ced2eb6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_2b32e97849"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
);
CREATE INDEX "index_character_friends_on_user_id" ON "character_friends" ("user_id");
CREATE INDEX "index_character_friends_on_character_id" ON "character_friends" ("character_id");
CREATE TABLE IF NOT EXISTS "character_companions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "companion_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_4b01e494ea"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_f280932d6e"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
);
CREATE INDEX "index_character_companions_on_user_id" ON "character_companions" ("user_id");
CREATE INDEX "index_character_companions_on_character_id" ON "character_companions" ("character_id");
CREATE TABLE IF NOT EXISTS "character_birthtowns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "character_id" integer, "birthtown_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a95fa4c433"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ae9d7e5838"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
);
CREATE INDEX "index_character_birthtowns_on_user_id" ON "character_birthtowns" ("user_id");
CREATE INDEX "index_character_birthtowns_on_character_id" ON "character_birthtowns" ("character_id");
CREATE TABLE IF NOT EXISTS "location_capital_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "location_id" integer, "capital_town_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_93d92763d1"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
, CONSTRAINT "fk_rails_6bfbd81832"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_location_capital_towns_on_location_id" ON "location_capital_towns" ("location_id");
CREATE INDEX "index_location_capital_towns_on_user_id" ON "location_capital_towns" ("user_id");
CREATE TABLE IF NOT EXISTS "location_largest_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "location_id" integer, "largest_town_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b7a61dda35"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
, CONSTRAINT "fk_rails_b9aaa9f7f3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_location_largest_towns_on_location_id" ON "location_largest_towns" ("location_id");
CREATE INDEX "index_location_largest_towns_on_user_id" ON "location_largest_towns" ("user_id");
CREATE TABLE IF NOT EXISTS "location_notable_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "location_id" integer, "notable_town_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b17ee570a3"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
, CONSTRAINT "fk_rails_3e58cbbccf"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_location_notable_towns_on_location_id" ON "location_notable_towns" ("location_id");
CREATE INDEX "index_location_notable_towns_on_user_id" ON "location_notable_towns" ("user_id");
CREATE TABLE IF NOT EXISTS "location_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "location_id" integer, "landmark_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_af0f6a5143"
FOREIGN KEY ("location_id")
  REFERENCES "locations" ("id")
, CONSTRAINT "fk_rails_c7bb0c048a"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
, CONSTRAINT "fk_rails_d9e4614728"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_location_landmarks_on_location_id" ON "location_landmarks" ("location_id");
CREATE INDEX "index_location_landmarks_on_landmark_id" ON "location_landmarks" ("landmark_id");
CREATE INDEX "index_location_landmarks_on_user_id" ON "location_landmarks" ("user_id");
CREATE TABLE IF NOT EXISTS "item_magics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "item_id" integer, "magic_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_16e5446872"
FOREIGN KEY ("item_id")
  REFERENCES "items" ("id")
, CONSTRAINT "fk_rails_c055deed1c"
FOREIGN KEY ("magic_id")
  REFERENCES "magics" ("id")
, CONSTRAINT "fk_rails_8a5761705f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_item_magics_on_item_id" ON "item_magics" ("item_id");
CREATE INDEX "index_item_magics_on_magic_id" ON "item_magics" ("magic_id");
CREATE INDEX "index_item_magics_on_user_id" ON "item_magics" ("user_id");
CREATE TABLE IF NOT EXISTS "country_governments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "country_id" integer, "government_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_09023d7126"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_22db33f2f2"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_839218783a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_country_governments_on_country_id" ON "country_governments" ("country_id");
CREATE INDEX "index_country_governments_on_government_id" ON "country_governments" ("government_id");
CREATE INDEX "index_country_governments_on_user_id" ON "country_governments" ("user_id");
CREATE TABLE IF NOT EXISTS "group_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "group_id" integer, "creature_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_63e037973f"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
, CONSTRAINT "fk_rails_0af3bcda2d"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
, CONSTRAINT "fk_rails_860840595e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_group_creatures_on_group_id" ON "group_creatures" ("group_id");
CREATE INDEX "index_group_creatures_on_creature_id" ON "group_creatures" ("creature_id");
CREATE INDEX "index_group_creatures_on_user_id" ON "group_creatures" ("user_id");
CREATE TABLE IF NOT EXISTS "character_magics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "character_id" integer, "magic_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_8d35c61a0a"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_c7f106d7a8"
FOREIGN KEY ("magic_id")
  REFERENCES "magics" ("id")
, CONSTRAINT "fk_rails_c7c0b2560f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_character_magics_on_character_id" ON "character_magics" ("character_id");
CREATE INDEX "index_character_magics_on_magic_id" ON "character_magics" ("magic_id");
CREATE INDEX "index_character_magics_on_user_id" ON "character_magics" ("user_id");
CREATE TABLE IF NOT EXISTS "character_enemies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "character_id" integer, "enemy_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_278fe77f11"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_86bd911a0d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_character_enemies_on_character_id" ON "character_enemies" ("character_id");
CREATE INDEX "index_character_enemies_on_user_id" ON "character_enemies" ("user_id");
CREATE TABLE IF NOT EXISTS "deity_character_siblings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "deity_id" integer, "character_sibling_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b07a172902"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_38af9ca72a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_deity_character_siblings_on_deity_id" ON "deity_character_siblings" ("deity_id");
CREATE INDEX "index_deity_character_siblings_on_user_id" ON "deity_character_siblings" ("user_id");
CREATE TABLE IF NOT EXISTS "deity_deity_siblings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "deity_id" integer, "deity_sibling_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_ef89149eed"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_1f08fe24c9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_deity_deity_siblings_on_deity_id" ON "deity_deity_siblings" ("deity_id");
CREATE INDEX "index_deity_deity_siblings_on_user_id" ON "deity_deity_siblings" ("user_id");
CREATE TABLE IF NOT EXISTS "deity_races" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "deity_id" integer, "race_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_16cf1be6e3"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_2f4861f981"
FOREIGN KEY ("race_id")
  REFERENCES "races" ("id")
, CONSTRAINT "fk_rails_bc67686fb4"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_deity_races_on_deity_id" ON "deity_races" ("deity_id");
CREATE INDEX "index_deity_races_on_race_id" ON "deity_races" ("race_id");
CREATE INDEX "index_deity_races_on_user_id" ON "deity_races" ("user_id");
CREATE TABLE IF NOT EXISTS "religion_deities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "religion_id" integer, "deity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_c8b91c9617"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_5b20870439"
FOREIGN KEY ("religion_id")
  REFERENCES "religions" ("id")
, CONSTRAINT "fk_rails_1b2019c8b8"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
);
CREATE INDEX "index_religion_deities_on_user_id" ON "religion_deities" ("user_id");
CREATE INDEX "index_religion_deities_on_religion_id" ON "religion_deities" ("religion_id");
CREATE INDEX "index_religion_deities_on_deity_id" ON "religion_deities" ("deity_id");
CREATE INDEX "index_attributes_on_user_id" ON "attributes" ("user_id");
CREATE INDEX "index_attributes_on_user_id_and_attribute_field_id" ON "attributes" ("user_id", "attribute_field_id");
CREATE INDEX "index_attributes_on_entity_type_and_entity_id" ON "attributes" ("entity_type", "entity_id");
CREATE INDEX "deleted_at__attribute_field_id__entity_type_and_id" ON "attributes" ("deleted_at", "attribute_field_id", "entity_type", "entity_id");
CREATE TABLE IF NOT EXISTS "api_keys" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "key" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_32c28d0dc2"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_api_keys_on_user_id" ON "api_keys" ("user_id");
CREATE INDEX "index_lingualisms_on_spoken_language_id" ON "lingualisms" ("spoken_language_id");
CREATE TABLE IF NOT EXISTS "thredded_user_topic_read_states" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer NOT NULL, "postable_id" integer NOT NULL, "read_at" datetime NOT NULL, "unread_posts_count" integer DEFAULT 0 NOT NULL, "read_posts_count" integer DEFAULT 0 NOT NULL, "messageboard_id" integer NOT NULL);
CREATE UNIQUE INDEX "thredded_user_topic_read_states_user_postable" ON "thredded_user_topic_read_states" ("user_id", "postable_id");
CREATE INDEX "index_thredded_user_topic_read_states_on_messageboard_id" ON "thredded_user_topic_read_states" ("messageboard_id");
CREATE INDEX "thredded_user_topic_read_states_user_messageboard" ON "thredded_user_topic_read_states" ("user_id", "messageboard_id");
CREATE TABLE IF NOT EXISTS "content_pages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "description" varchar, "user_id" integer, "universe_id" integer, "deleted_at" datetime, "privacy" varchar, "page_type" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime, CONSTRAINT "fk_rails_e14182d024"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_b998e0001f"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_content_pages_on_user_id" ON "content_pages" ("user_id");
CREATE INDEX "index_content_pages_on_universe_id" ON "content_pages" ("universe_id");
CREATE INDEX "index_attributes_on_attribute_field_id_and_deleted_at" ON "attributes" ("attribute_field_id", "deleted_at");
CREATE INDEX "attributes_afi_deleted_at_entity_id_entity_type" ON "attributes" ("attribute_field_id", "deleted_at", "entity_id", "entity_type");
CREATE TABLE IF NOT EXISTS "thredded_user_details" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer NOT NULL, "latest_activity_at" datetime DEFAULT NULL, "posts_count" integer DEFAULT 0, "topics_count" integer DEFAULT 0, "last_seen_at" datetime DEFAULT NULL, "moderation_state" integer DEFAULT 1 NOT NULL, "moderation_state_changed_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_thredded_user_details_for_moderations" ON "thredded_user_details" ("moderation_state", "moderation_state_changed_at");
CREATE INDEX "index_thredded_user_details_on_latest_activity_at" ON "thredded_user_details" ("latest_activity_at");
CREATE UNIQUE INDEX "index_thredded_user_details_on_user_id" ON "thredded_user_details" ("user_id");
CREATE TABLE IF NOT EXISTS "page_tags" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "page_type" varchar, "page_id" integer, "tag" varchar, "slug" varchar, "color" varchar, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a4854d982e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_page_tags_on_page_type_and_page_id" ON "page_tags" ("page_type", "page_id");
CREATE INDEX "index_page_tags_on_user_id" ON "page_tags" ("user_id");
CREATE INDEX "index_page_tags_on_user_id_and_page_type" ON "page_tags" ("user_id", "page_type");
CREATE TABLE IF NOT EXISTS "document_entities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "entity_type" varchar, "entity_id" integer, "text" varchar, "relevance" float, "document_analysis_id" integer, "sentiment_label" varchar, "sentiment_score" float, "sadness_score" float, "joy_score" float, "fear_score" float, "disgust_score" float, "anger_score" float, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_eba19193fd"
FOREIGN KEY ("document_analysis_id")
  REFERENCES "document_analyses" ("id")
);
CREATE INDEX "index_document_entities_on_entity_type_and_entity_id" ON "document_entities" ("entity_type", "entity_id");
CREATE INDEX "index_document_entities_on_document_analysis_id" ON "document_entities" ("document_analysis_id");
CREATE TABLE IF NOT EXISTS "document_concepts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "document_analysis_id" integer, "text" varchar, "relevance" float, "reference_link" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_3a3ae44ed1"
FOREIGN KEY ("document_analysis_id")
  REFERENCES "document_analyses" ("id")
);
CREATE INDEX "index_document_concepts_on_document_analysis_id" ON "document_concepts" ("document_analysis_id");
CREATE TABLE IF NOT EXISTS "document_categories" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "document_analysis_id" integer, "label" varchar, "score" float, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_cbd8ef1f3d"
FOREIGN KEY ("document_analysis_id")
  REFERENCES "document_analyses" ("id")
);
CREATE INDEX "index_document_categories_on_document_analysis_id" ON "document_categories" ("document_analysis_id");
CREATE TABLE IF NOT EXISTS "notice_dismissals" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "notice_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_7459c5b86c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_notice_dismissals_on_user_id" ON "notice_dismissals" ("user_id");
CREATE TABLE IF NOT EXISTS "page_unlock_promo_codes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "code" varchar, "page_types" varchar, "uses_remaining" integer, "days_active" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "internal_description" varchar, "description" varchar);
CREATE TABLE IF NOT EXISTS "promotions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "page_unlock_promo_code_id" integer, "expires_at" datetime, "content_type" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_fffaee91fa"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_16ea4089a3"
FOREIGN KEY ("page_unlock_promo_code_id")
  REFERENCES "page_unlock_promo_codes" ("id")
);
CREATE INDEX "index_promotions_on_user_id" ON "promotions" ("user_id");
CREATE INDEX "index_promotions_on_page_unlock_promo_code_id" ON "promotions" ("page_unlock_promo_code_id");
CREATE TABLE IF NOT EXISTS "documents" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "body" text DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "title" varchar DEFAULT 'Untitled document', "privacy" varchar DEFAULT 'private', "synopsis" text DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "universe_id" integer DEFAULT NULL, "favorite" boolean, "notes_text" text, CONSTRAINT "fk_rails_2be0318c46"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_7a0a570ba1"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_documents_on_user_id" ON "documents" ("user_id");
CREATE INDEX "index_documents_on_universe_id" ON "documents" ("universe_id");
CREATE INDEX "index_documents_on_universe_id_and_deleted_at" ON "documents" ("universe_id", "deleted_at");
CREATE INDEX "index_attributes_on_user_id_and_deleted_at" ON "attributes" ("user_id", "deleted_at");
CREATE INDEX "attributes_afi_ui_et_ei_da" ON "attributes" ("attribute_field_id", "user_id", "entity_type", "entity_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "page_settings_overrides" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "page_type" varchar, "name_override" varchar, "icon_override" varchar, "hex_color_override" varchar, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_page_settings_overrides_on_user_id" ON "page_settings_overrides" ("user_id");
CREATE TABLE IF NOT EXISTS "active_storage_blobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "key" varchar NOT NULL, "filename" varchar NOT NULL, "content_type" varchar, "metadata" text, "byte_size" bigint NOT NULL, "checksum" varchar NOT NULL, "created_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_active_storage_blobs_on_key" ON "active_storage_blobs" ("key");
CREATE TABLE IF NOT EXISTS "active_storage_attachments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "record_type" varchar NOT NULL, "record_id" integer NOT NULL, "blob_id" integer NOT NULL, "created_at" datetime NOT NULL, CONSTRAINT "fk_rails_c3b3935057"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE INDEX "index_active_storage_attachments_on_blob_id" ON "active_storage_attachments" ("blob_id");
CREATE UNIQUE INDEX "index_active_storage_attachments_uniqueness" ON "active_storage_attachments" ("record_type", "record_id", "name", "blob_id");
CREATE TABLE IF NOT EXISTS "attribute_categories" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "entity_type" varchar DEFAULT NULL, "name" varchar NOT NULL, "label" varchar NOT NULL, "icon" varchar DEFAULT NULL, "description" text DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "hidden" boolean DEFAULT 0, "deleted_at" datetime DEFAULT NULL, "position" integer DEFAULT NULL);
CREATE INDEX "index_attribute_categories_on_entity_type" ON "attribute_categories" ("entity_type");
CREATE INDEX "index_attribute_categories_on_name" ON "attribute_categories" ("name");
CREATE INDEX "index_attribute_categories_on_user_id" ON "attribute_categories" ("user_id");
CREATE INDEX "index_attribute_categories_on_entity_type_and_name_and_user_id" ON "attribute_categories" ("entity_type", "name", "user_id");
CREATE TABLE IF NOT EXISTS "attribute_field_suggestions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "entity_type" varchar, "category_label" varchar, "suggestion" varchar, "weight" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "attribute_category_suggestions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "entity_type" varchar, "suggestion" varchar, "weight" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE INDEX "index_subscriptions_on_user_id_and_start_date_and_end_date" ON "subscriptions" ("user_id", "start_date", "end_date");
CREATE INDEX "index_promotions_on_user_id_and_expires_at" ON "promotions" ("user_id", "expires_at");
CREATE TABLE IF NOT EXISTS "paypal_invoices" ("id" integer NOT NULL PRIMARY KEY, "paypal_id" varchar DEFAULT NULL, "status" varchar DEFAULT NULL, "user_id" integer NOT NULL, "months" integer DEFAULT NULL, "amount_cents" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "page_unlock_promo_code_id" integer DEFAULT NULL, "approval_url" varchar, "payer_id" varchar, "deleted_at" datetime, CONSTRAINT "fk_rails_e8eab5c9a7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_0e6faa54e5"
FOREIGN KEY ("page_unlock_promo_code_id")
  REFERENCES "page_unlock_promo_codes" ("id")
);
CREATE INDEX "index_paypal_invoices_on_user_id" ON "paypal_invoices" ("user_id");
CREATE INDEX "index_paypal_invoices_on_page_unlock_promo_code_id" ON "paypal_invoices" ("page_unlock_promo_code_id");
CREATE TABLE IF NOT EXISTS "continent_countries" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "country_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d6def629e5"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_c36b7cdfc0"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_b4222060dc"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_countries_on_continent_id" ON "continent_countries" ("continent_id");
CREATE INDEX "index_continent_countries_on_country_id" ON "continent_countries" ("country_id");
CREATE INDEX "index_continent_countries_on_user_id" ON "continent_countries" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_creatures" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "creature_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3b4205b29f"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ce6a782d57"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
, CONSTRAINT "fk_rails_c5f99896e6"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_creatures_on_continent_id" ON "continent_creatures" ("continent_id");
CREATE INDEX "index_continent_creatures_on_creature_id" ON "continent_creatures" ("creature_id");
CREATE INDEX "index_continent_creatures_on_user_id" ON "continent_creatures" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_floras" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "flora_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e7783bd156"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_eedfb1da43"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
, CONSTRAINT "fk_rails_757249240c"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_floras_on_continent_id" ON "continent_floras" ("continent_id");
CREATE INDEX "index_continent_floras_on_flora_id" ON "continent_floras" ("flora_id");
CREATE INDEX "index_continent_floras_on_user_id" ON "continent_floras" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_governments" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "government_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_8ac58d75ab"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_d926f2d333"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_f2550b14aa"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_governments_on_continent_id" ON "continent_governments" ("continent_id");
CREATE INDEX "index_continent_governments_on_government_id" ON "continent_governments" ("government_id");
CREATE INDEX "index_continent_governments_on_user_id" ON "continent_governments" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_landmarks" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "landmark_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "user_id" integer DEFAULT NULL, CONSTRAINT "fk_rails_38f6d5b974"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_50bc6ca82d"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
, CONSTRAINT "fk_rails_40b95db99c"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
);
CREATE INDEX "index_continent_landmarks_on_continent_id" ON "continent_landmarks" ("continent_id");
CREATE INDEX "index_continent_landmarks_on_landmark_id" ON "continent_landmarks" ("landmark_id");
CREATE INDEX "index_continent_landmarks_on_user_id" ON "continent_landmarks" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_languages" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "language_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_5cfcd78702"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ed26e147fc"
FOREIGN KEY ("language_id")
  REFERENCES "languages" ("id")
, CONSTRAINT "fk_rails_336a88428d"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_languages_on_continent_id" ON "continent_languages" ("continent_id");
CREATE INDEX "index_continent_languages_on_language_id" ON "continent_languages" ("language_id");
CREATE INDEX "index_continent_languages_on_user_id" ON "continent_languages" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_popular_foods" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "popular_food_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_f09fffaa4d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_f0782030ed"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_popular_foods_on_continent_id" ON "continent_popular_foods" ("continent_id");
CREATE INDEX "index_continent_popular_foods_on_user_id" ON "continent_popular_foods" ("user_id");
CREATE TABLE IF NOT EXISTS "continent_traditions" ("id" integer NOT NULL PRIMARY KEY, "continent_id" integer NOT NULL, "tradition_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_4f9410751c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_6036d4a67f"
FOREIGN KEY ("tradition_id")
  REFERENCES "traditions" ("id")
, CONSTRAINT "fk_rails_75f882e414"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
);
CREATE INDEX "index_continent_traditions_on_continent_id" ON "continent_traditions" ("continent_id");
CREATE INDEX "index_continent_traditions_on_tradition_id" ON "continent_traditions" ("tradition_id");
CREATE INDEX "index_continent_traditions_on_user_id" ON "continent_traditions" ("user_id");
CREATE TABLE IF NOT EXISTS "planet_continents" ("id" integer NOT NULL PRIMARY KEY, "planet_id" integer NOT NULL, "continent_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_af8fa7ca12"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_e164ac0d81"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
, CONSTRAINT "fk_rails_3710eaf0d9"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
);
CREATE INDEX "index_planet_continents_on_planet_id" ON "planet_continents" ("planet_id");
CREATE INDEX "index_planet_continents_on_continent_id" ON "planet_continents" ("continent_id");
CREATE INDEX "index_planet_continents_on_user_id" ON "planet_continents" ("user_id");
CREATE TABLE IF NOT EXISTS "country_bordering_countries" ("id" integer NOT NULL PRIMARY KEY, "country_id" integer NOT NULL, "bordering_country_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1ec453531c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_f580cb070a"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
);
CREATE INDEX "index_country_bordering_countries_on_country_id" ON "country_bordering_countries" ("country_id");
CREATE INDEX "index_country_bordering_countries_on_user_id" ON "country_bordering_countries" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_planets" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "planet_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_52e90c6e52"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_d916e70471"
FOREIGN KEY ("planet_id")
  REFERENCES "planets" ("id")
, CONSTRAINT "fk_rails_d3b6775521"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_planets_on_lore_id" ON "lore_planets" ("lore_id");
CREATE INDEX "index_lore_planets_on_planet_id" ON "lore_planets" ("planet_id");
CREATE INDEX "index_lore_planets_on_user_id" ON "lore_planets" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_continents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "continent_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3f582ddff0"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_7ef5e49d43"
FOREIGN KEY ("continent_id")
  REFERENCES "continents" ("id")
, CONSTRAINT "fk_rails_fc380e6891"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_continents_on_lore_id" ON "lore_continents" ("lore_id");
CREATE INDEX "index_lore_continents_on_continent_id" ON "lore_continents" ("continent_id");
CREATE INDEX "index_lore_continents_on_user_id" ON "lore_continents" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "country_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d799c80ed2"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_f3fbfead99"
FOREIGN KEY ("country_id")
  REFERENCES "countries" ("id")
, CONSTRAINT "fk_rails_49c240fdeb"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_countries_on_lore_id" ON "lore_countries" ("lore_id");
CREATE INDEX "index_lore_countries_on_country_id" ON "lore_countries" ("country_id");
CREATE INDEX "index_lore_countries_on_user_id" ON "lore_countries" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "landmark_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_6504914f73"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_844c7919c8"
FOREIGN KEY ("landmark_id")
  REFERENCES "landmarks" ("id")
, CONSTRAINT "fk_rails_2920622146"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_landmarks_on_lore_id" ON "lore_landmarks" ("lore_id");
CREATE INDEX "index_lore_landmarks_on_landmark_id" ON "lore_landmarks" ("landmark_id");
CREATE INDEX "index_lore_landmarks_on_user_id" ON "lore_landmarks" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "town_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_8007529ef0"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_d9b11f633b"
FOREIGN KEY ("town_id")
  REFERENCES "towns" ("id")
, CONSTRAINT "fk_rails_97c7a64604"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_towns_on_lore_id" ON "lore_towns" ("lore_id");
CREATE INDEX "index_lore_towns_on_town_id" ON "lore_towns" ("town_id");
CREATE INDEX "index_lore_towns_on_user_id" ON "lore_towns" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_buildings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "building_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_a987c38bd5"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_3c7bf0f39c"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
, CONSTRAINT "fk_rails_50c2667644"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_buildings_on_lore_id" ON "lore_buildings" ("lore_id");
CREATE INDEX "index_lore_buildings_on_building_id" ON "lore_buildings" ("building_id");
CREATE INDEX "index_lore_buildings_on_user_id" ON "lore_buildings" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_schools" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "school_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b4394c2f72"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_89a69abd11"
FOREIGN KEY ("school_id")
  REFERENCES "schools" ("id")
, CONSTRAINT "fk_rails_0a7e174039"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_schools_on_lore_id" ON "lore_schools" ("lore_id");
CREATE INDEX "index_lore_schools_on_school_id" ON "lore_schools" ("school_id");
CREATE INDEX "index_lore_schools_on_user_id" ON "lore_schools" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_characters" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "character_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_28ac437043"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_c4e908753f"
FOREIGN KEY ("character_id")
  REFERENCES "characters" ("id")
, CONSTRAINT "fk_rails_602827c16a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_characters_on_lore_id" ON "lore_characters" ("lore_id");
CREATE INDEX "index_lore_characters_on_character_id" ON "lore_characters" ("character_id");
CREATE INDEX "index_lore_characters_on_user_id" ON "lore_characters" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_deities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "deity_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_6ca57c7214"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_938c9412ec"
FOREIGN KEY ("deity_id")
  REFERENCES "deities" ("id")
, CONSTRAINT "fk_rails_9b677d31b3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_deities_on_lore_id" ON "lore_deities" ("lore_id");
CREATE INDEX "index_lore_deities_on_deity_id" ON "lore_deities" ("deity_id");
CREATE INDEX "index_lore_deities_on_user_id" ON "lore_deities" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_creatures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "creature_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_2f8c8cc7c1"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_f561aabd30"
FOREIGN KEY ("creature_id")
  REFERENCES "creatures" ("id")
, CONSTRAINT "fk_rails_b89de05250"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_creatures_on_lore_id" ON "lore_creatures" ("lore_id");
CREATE INDEX "index_lore_creatures_on_creature_id" ON "lore_creatures" ("creature_id");
CREATE INDEX "index_lore_creatures_on_user_id" ON "lore_creatures" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_floras" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "flora_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_9423b9b2dd"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_d34937a68f"
FOREIGN KEY ("flora_id")
  REFERENCES "floras" ("id")
, CONSTRAINT "fk_rails_1c9193771e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_floras_on_lore_id" ON "lore_floras" ("lore_id");
CREATE INDEX "index_lore_floras_on_flora_id" ON "lore_floras" ("flora_id");
CREATE INDEX "index_lore_floras_on_user_id" ON "lore_floras" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_jobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "job_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_52d45664c9"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_a68c69daea"
FOREIGN KEY ("job_id")
  REFERENCES "jobs" ("id")
, CONSTRAINT "fk_rails_d6f3e1e9db"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_jobs_on_lore_id" ON "lore_jobs" ("lore_id");
CREATE INDEX "index_lore_jobs_on_job_id" ON "lore_jobs" ("job_id");
CREATE INDEX "index_lore_jobs_on_user_id" ON "lore_jobs" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_technologies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "technology_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_cb260b4429"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_22bddd59b6"
FOREIGN KEY ("technology_id")
  REFERENCES "technologies" ("id")
, CONSTRAINT "fk_rails_3f06f7f0f9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_technologies_on_lore_id" ON "lore_technologies" ("lore_id");
CREATE INDEX "index_lore_technologies_on_technology_id" ON "lore_technologies" ("technology_id");
CREATE INDEX "index_lore_technologies_on_user_id" ON "lore_technologies" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_vehicles" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "vehicle_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b898d20525"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_33d25bb9cc"
FOREIGN KEY ("vehicle_id")
  REFERENCES "vehicles" ("id")
, CONSTRAINT "fk_rails_f3845e4b82"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_vehicles_on_lore_id" ON "lore_vehicles" ("lore_id");
CREATE INDEX "index_lore_vehicles_on_vehicle_id" ON "lore_vehicles" ("vehicle_id");
CREATE INDEX "index_lore_vehicles_on_user_id" ON "lore_vehicles" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_conditions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "condition_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_09d0d51048"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_5bfc89f70c"
FOREIGN KEY ("condition_id")
  REFERENCES "conditions" ("id")
, CONSTRAINT "fk_rails_e02e24e2c5"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_conditions_on_lore_id" ON "lore_conditions" ("lore_id");
CREATE INDEX "index_lore_conditions_on_condition_id" ON "lore_conditions" ("condition_id");
CREATE INDEX "index_lore_conditions_on_user_id" ON "lore_conditions" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_races" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "race_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_37eea989e3"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_9bcbf303ab"
FOREIGN KEY ("race_id")
  REFERENCES "races" ("id")
, CONSTRAINT "fk_rails_1c791f7ea9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_races_on_lore_id" ON "lore_races" ("lore_id");
CREATE INDEX "index_lore_races_on_race_id" ON "lore_races" ("race_id");
CREATE INDEX "index_lore_races_on_user_id" ON "lore_races" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_religions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "religion_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_43315fbe2e"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_a409b836c0"
FOREIGN KEY ("religion_id")
  REFERENCES "religions" ("id")
, CONSTRAINT "fk_rails_ef9b8612fb"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_religions_on_lore_id" ON "lore_religions" ("lore_id");
CREATE INDEX "index_lore_religions_on_religion_id" ON "lore_religions" ("religion_id");
CREATE INDEX "index_lore_religions_on_user_id" ON "lore_religions" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_magics" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "magic_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3887a53a99"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_5153e59bb7"
FOREIGN KEY ("magic_id")
  REFERENCES "magics" ("id")
, CONSTRAINT "fk_rails_e2cf738d18"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_magics_on_lore_id" ON "lore_magics" ("lore_id");
CREATE INDEX "index_lore_magics_on_magic_id" ON "lore_magics" ("magic_id");
CREATE INDEX "index_lore_magics_on_user_id" ON "lore_magics" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_governments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "government_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_95ae8915de"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_81895c349a"
FOREIGN KEY ("government_id")
  REFERENCES "governments" ("id")
, CONSTRAINT "fk_rails_364507f55b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_governments_on_lore_id" ON "lore_governments" ("lore_id");
CREATE INDEX "index_lore_governments_on_government_id" ON "lore_governments" ("government_id");
CREATE INDEX "index_lore_governments_on_user_id" ON "lore_governments" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_groups" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "group_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_10ee16fd87"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_423b7b9b62"
FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
, CONSTRAINT "fk_rails_23cb02a0f0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_groups_on_lore_id" ON "lore_groups" ("lore_id");
CREATE INDEX "index_lore_groups_on_group_id" ON "lore_groups" ("group_id");
CREATE INDEX "index_lore_groups_on_user_id" ON "lore_groups" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_traditions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "tradition_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_cb114109a9"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_bc92f33499"
FOREIGN KEY ("tradition_id")
  REFERENCES "traditions" ("id")
, CONSTRAINT "fk_rails_a555a3bfde"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_traditions_on_lore_id" ON "lore_traditions" ("lore_id");
CREATE INDEX "index_lore_traditions_on_tradition_id" ON "lore_traditions" ("tradition_id");
CREATE INDEX "index_lore_traditions_on_user_id" ON "lore_traditions" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_foods" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "food_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_fbee4b6849"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_5e3d3fd8e4"
FOREIGN KEY ("food_id")
  REFERENCES "foods" ("id")
, CONSTRAINT "fk_rails_d0fb1daa7b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_foods_on_lore_id" ON "lore_foods" ("lore_id");
CREATE INDEX "index_lore_foods_on_food_id" ON "lore_foods" ("food_id");
CREATE INDEX "index_lore_foods_on_user_id" ON "lore_foods" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_sports" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "sport_id" integer NOT NULL, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c1ea207ebf"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_4cb365bfbc"
FOREIGN KEY ("sport_id")
  REFERENCES "sports" ("id")
, CONSTRAINT "fk_rails_4c65c64f59"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_sports_on_lore_id" ON "lore_sports" ("lore_id");
CREATE INDEX "index_lore_sports_on_sport_id" ON "lore_sports" ("sport_id");
CREATE INDEX "index_lore_sports_on_user_id" ON "lore_sports" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_believers" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "believer_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_15d8dec892"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_625715e589"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_believers_on_lore_id" ON "lore_believers" ("lore_id");
CREATE INDEX "index_lore_believers_on_user_id" ON "lore_believers" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_created_traditions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "created_tradition_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_94a9348d70"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_f7f2869fc2"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_created_traditions_on_lore_id" ON "lore_created_traditions" ("lore_id");
CREATE INDEX "index_lore_created_traditions_on_user_id" ON "lore_created_traditions" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_original_languages" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "original_language_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_2f03aa5fc9"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_50a1d48d4c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_original_languages_on_lore_id" ON "lore_original_languages" ("lore_id");
CREATE INDEX "index_lore_original_languages_on_user_id" ON "lore_original_languages" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_variations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "variation_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d8c9ed5bfe"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_6b1d33483c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_variations_on_lore_id" ON "lore_variations" ("lore_id");
CREATE INDEX "index_lore_variations_on_user_id" ON "lore_variations" ("user_id");
CREATE TABLE IF NOT EXISTS "lore_related_lores" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "lore_id" integer NOT NULL, "related_lore_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b0a8cb9c9e"
FOREIGN KEY ("lore_id")
  REFERENCES "lores" ("id")
, CONSTRAINT "fk_rails_e0f705d79d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lore_related_lores_on_lore_id" ON "lore_related_lores" ("lore_id");
CREATE INDEX "index_lore_related_lores_on_user_id" ON "lore_related_lores" ("user_id");
CREATE TABLE IF NOT EXISTS "lores" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer NOT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "archived_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "favorite" boolean DEFAULT NULL, "page_type" varchar DEFAULT 'Lore', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_663908ae63"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_6050035822"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_lores_on_user_id" ON "lores" ("user_id");
CREATE INDEX "index_lores_on_universe_id" ON "lores" ("universe_id");
CREATE TABLE IF NOT EXISTS "user_followings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "followed_user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3c1bb51b2d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_user_followings_on_user_id" ON "user_followings" ("user_id");
CREATE INDEX "index_user_followings_on_followed_user_id" ON "user_followings" ("followed_user_id");
CREATE TABLE IF NOT EXISTS "user_blockings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "blocked_user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_4cc7a9066b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_user_blockings_on_user_id" ON "user_blockings" ("user_id");
CREATE INDEX "index_user_blockings_on_blocked_user_id" ON "user_blockings" ("blocked_user_id");
CREATE TABLE IF NOT EXISTS "universes" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "description" text DEFAULT NULL, "history" text DEFAULT NULL, "notes" text DEFAULT NULL, "private_notes" text DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "laws_of_physics" varchar DEFAULT NULL, "magic_system" varchar DEFAULT NULL, "technology" varchar DEFAULT NULL, "genre" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Universe', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_universes_on_deleted_at" ON "universes" ("deleted_at");
CREATE INDEX "index_universes_on_user_id" ON "universes" ("user_id");
CREATE INDEX "index_universes_on_deleted_at_and_id" ON "universes" ("deleted_at", "id");
CREATE INDEX "index_universes_on_deleted_at_and_user_id" ON "universes" ("deleted_at", "user_id");
CREATE INDEX "index_universes_on_id_and_deleted_at" ON "universes" ("id", "deleted_at");
CREATE TABLE IF NOT EXISTS "characters" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "role" varchar DEFAULT NULL, "gender" varchar DEFAULT NULL, "age" varchar DEFAULT NULL, "height" varchar DEFAULT NULL, "weight" varchar DEFAULT NULL, "haircolor" varchar DEFAULT NULL, "hairstyle" varchar DEFAULT NULL, "facialhair" varchar DEFAULT NULL, "eyecolor" varchar DEFAULT NULL, "race" varchar DEFAULT NULL, "skintone" varchar DEFAULT NULL, "bodytype" varchar DEFAULT NULL, "identmarks" varchar DEFAULT NULL, "religion" text DEFAULT NULL, "politics" text DEFAULT NULL, "prejudices" text DEFAULT NULL, "occupation" text DEFAULT NULL, "pets" text DEFAULT NULL, "mannerisms" text DEFAULT NULL, "birthday" text DEFAULT NULL, "birthplace" text DEFAULT NULL, "education" text DEFAULT NULL, "background" text DEFAULT NULL, "fave_color" varchar DEFAULT NULL, "fave_food" varchar DEFAULT NULL, "fave_possession" varchar DEFAULT NULL, "fave_weapon" varchar DEFAULT NULL, "fave_animal" varchar DEFAULT NULL, "notes" text DEFAULT NULL, "private_notes" text DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "archetype" varchar DEFAULT NULL, "aliases" varchar DEFAULT NULL, "motivations" varchar DEFAULT NULL, "flaws" varchar DEFAULT NULL, "talents" varchar DEFAULT NULL, "hobbies" varchar DEFAULT NULL, "personality_type" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Character', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_characters_on_deleted_at" ON "characters" ("deleted_at");
CREATE INDEX "index_characters_on_universe_id" ON "characters" ("universe_id");
CREATE INDEX "index_characters_on_user_id" ON "characters" ("user_id");
CREATE INDEX "index_characters_on_deleted_at_and_id" ON "characters" ("deleted_at", "id");
CREATE INDEX "index_characters_on_deleted_at_and_user_id" ON "characters" ("deleted_at", "user_id");
CREATE INDEX "index_characters_on_deleted_at_and_universe_id" ON "characters" ("deleted_at", "universe_id");
CREATE INDEX "index_characters_on_id_and_deleted_at" ON "characters" ("id", "deleted_at");
CREATE INDEX "index_characters_on_user_id_and_universe_id_and_deleted_at" ON "characters" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "locations" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "type_of" varchar DEFAULT NULL, "description" text DEFAULT NULL, "map_file_name" varchar DEFAULT NULL, "map_content_type" varchar DEFAULT NULL, "map_file_size" integer DEFAULT NULL, "map_updated_at" datetime DEFAULT NULL, "population" varchar DEFAULT NULL, "language" varchar DEFAULT NULL, "currency" varchar DEFAULT NULL, "motto" varchar DEFAULT NULL, "capital" text DEFAULT NULL, "largest_city" text DEFAULT NULL, "notable_cities" text DEFAULT NULL, "area" text DEFAULT NULL, "crops" text DEFAULT NULL, "located_at" text DEFAULT NULL, "established_year" varchar DEFAULT NULL, "notable_wars" text DEFAULT NULL, "notes" text DEFAULT NULL, "private_notes" text DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT 'private' NOT NULL, "laws" varchar DEFAULT NULL, "climate" varchar DEFAULT NULL, "founding_story" varchar DEFAULT NULL, "sports" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Location', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_locations_on_deleted_at" ON "locations" ("deleted_at");
CREATE INDEX "index_locations_on_user_id" ON "locations" ("user_id");
CREATE INDEX "index_locations_on_universe_id" ON "locations" ("universe_id");
CREATE INDEX "index_locations_on_deleted_at_and_id" ON "locations" ("deleted_at", "id");
CREATE INDEX "index_locations_on_deleted_at_and_user_id" ON "locations" ("deleted_at", "user_id");
CREATE INDEX "index_locations_on_deleted_at_and_universe_id" ON "locations" ("deleted_at", "universe_id");
CREATE INDEX "index_locations_on_id_and_deleted_at" ON "locations" ("id", "deleted_at");
CREATE INDEX "index_locations_on_user_id_and_universe_id_and_deleted_at" ON "locations" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "items" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "item_type" varchar DEFAULT NULL, "description" text DEFAULT NULL, "weight" varchar DEFAULT NULL, "original_owner" varchar DEFAULT NULL, "current_owner" varchar DEFAULT NULL, "made_by" text DEFAULT NULL, "materials" text DEFAULT NULL, "year_made" varchar DEFAULT NULL, "magic" text DEFAULT NULL, "notes" text DEFAULT NULL, "private_notes" text DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT 'private' NOT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Item', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_items_on_deleted_at" ON "items" ("deleted_at");
CREATE INDEX "index_items_on_user_id" ON "items" ("user_id");
CREATE INDEX "index_items_on_universe_id" ON "items" ("universe_id");
CREATE INDEX "index_items_on_deleted_at_and_id" ON "items" ("deleted_at", "id");
CREATE INDEX "index_items_on_deleted_at_and_user_id" ON "items" ("deleted_at", "user_id");
CREATE INDEX "index_items_on_deleted_at_and_universe_id" ON "items" ("deleted_at", "universe_id");
CREATE INDEX "index_items_on_id_and_deleted_at" ON "items" ("id", "deleted_at");
CREATE INDEX "index_items_on_user_id_and_universe_id_and_deleted_at" ON "items" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "buildings" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Building', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_052dc245af"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_7091ae270b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_buildings_on_user_id" ON "buildings" ("user_id");
CREATE INDEX "index_buildings_on_universe_id" ON "buildings" ("universe_id");
CREATE INDEX "index_buildings_on_user_id_and_universe_id_and_deleted_at" ON "buildings" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "conditions" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Condition', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_e8c8480156"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_b8f2aeb6b9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_conditions_on_user_id" ON "conditions" ("user_id");
CREATE INDEX "index_conditions_on_universe_id" ON "conditions" ("universe_id");
CREATE INDEX "index_conditions_on_user_id_and_universe_id_and_deleted_at" ON "conditions" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "continents" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer NOT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Continent', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_89f34f2745"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_fefd082dbd"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_continents_on_user_id" ON "continents" ("user_id");
CREATE INDEX "index_continents_on_universe_id" ON "continents" ("universe_id");
CREATE INDEX "index_continents_on_deleted_at_and_id" ON "continents" ("deleted_at", "id");
CREATE INDEX "index_continents_on_deleted_at_and_id_and_universe_id" ON "continents" ("deleted_at", "id", "universe_id");
CREATE INDEX "index_continents_on_deleted_at_and_id_and_user_id" ON "continents" ("deleted_at", "id", "user_id");
CREATE INDEX "index_continents_on_deleted_at_and_user_id" ON "continents" ("deleted_at", "user_id");
CREATE TABLE IF NOT EXISTS "countries" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "population" varchar DEFAULT NULL, "currency" varchar DEFAULT NULL, "laws" varchar DEFAULT NULL, "sports" varchar DEFAULT NULL, "area" varchar DEFAULT NULL, "crops" varchar DEFAULT NULL, "climate" varchar DEFAULT NULL, "founding_story" varchar DEFAULT NULL, "established_year" varchar DEFAULT NULL, "notable_wars" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "page_type" varchar DEFAULT 'Country', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_4ea6d3a6e7"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_c75da215f2"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_countries_on_universe_id" ON "countries" ("universe_id");
CREATE INDEX "index_countries_on_user_id" ON "countries" ("user_id");
CREATE INDEX "index_countries_on_deleted_at_and_id" ON "countries" ("deleted_at", "id");
CREATE INDEX "index_countries_on_deleted_at_and_user_id" ON "countries" ("deleted_at", "user_id");
CREATE INDEX "index_countries_on_deleted_at_and_universe_id" ON "countries" ("deleted_at", "universe_id");
CREATE INDEX "index_countries_on_id_and_deleted_at" ON "countries" ("id", "deleted_at");
CREATE INDEX "index_countries_on_user_id_and_universe_id_and_deleted_at" ON "countries" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "creatures" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "type_of" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "color" varchar DEFAULT NULL, "shape" varchar DEFAULT NULL, "size" varchar DEFAULT NULL, "notable_features" varchar DEFAULT NULL, "materials" varchar DEFAULT NULL, "preferred_habitat" varchar DEFAULT NULL, "sounds" varchar DEFAULT NULL, "strengths" varchar DEFAULT NULL, "weaknesses" varchar DEFAULT NULL, "spoils" varchar DEFAULT NULL, "aggressiveness" varchar DEFAULT NULL, "attack_method" varchar DEFAULT NULL, "defense_method" varchar DEFAULT NULL, "maximum_speed" varchar DEFAULT NULL, "food_sources" varchar DEFAULT NULL, "migratory_patterns" varchar DEFAULT NULL, "reproduction" varchar DEFAULT NULL, "herd_patterns" varchar DEFAULT NULL, "similar_animals" varchar DEFAULT NULL, "symbolisms" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "user_id" integer DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "phylum" varchar DEFAULT NULL, "class_string" varchar DEFAULT NULL, "order" varchar DEFAULT NULL, "family" varchar DEFAULT NULL, "genus" varchar DEFAULT NULL, "species" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Creature', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_creatures_on_deleted_at" ON "creatures" ("deleted_at");
CREATE INDEX "index_creatures_on_user_id" ON "creatures" ("user_id");
CREATE INDEX "index_creatures_on_universe_id" ON "creatures" ("universe_id");
CREATE INDEX "index_creatures_on_deleted_at_and_id" ON "creatures" ("deleted_at", "id");
CREATE INDEX "index_creatures_on_deleted_at_and_user_id" ON "creatures" ("deleted_at", "user_id");
CREATE INDEX "index_creatures_on_deleted_at_and_universe_id" ON "creatures" ("deleted_at", "universe_id");
CREATE INDEX "index_creatures_on_id_and_deleted_at" ON "creatures" ("id", "deleted_at");
CREATE INDEX "index_creatures_on_user_id_and_universe_id_and_deleted_at" ON "creatures" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "deities" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "physical_description" varchar DEFAULT NULL, "height" varchar DEFAULT NULL, "weight" varchar DEFAULT NULL, "symbols" varchar DEFAULT NULL, "elements" varchar DEFAULT NULL, "strengths" varchar DEFAULT NULL, "weaknesses" varchar DEFAULT NULL, "prayers" varchar DEFAULT NULL, "rituals" varchar DEFAULT NULL, "human_interaction" varchar DEFAULT NULL, "notable_events" varchar DEFAULT NULL, "family_history" varchar DEFAULT NULL, "life_story" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "page_type" varchar DEFAULT 'Deity', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_deab325ea6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_657c8efe75"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_deities_on_user_id" ON "deities" ("user_id");
CREATE INDEX "index_deities_on_universe_id" ON "deities" ("universe_id");
CREATE INDEX "index_deities_on_deleted_at_and_id" ON "deities" ("deleted_at", "id");
CREATE INDEX "index_deities_on_deleted_at_and_user_id" ON "deities" ("deleted_at", "user_id");
CREATE INDEX "index_deities_on_deleted_at_and_universe_id" ON "deities" ("deleted_at", "universe_id");
CREATE INDEX "index_deities_on_id_and_deleted_at" ON "deities" ("id", "deleted_at");
CREATE INDEX "index_deities_on_user_id_and_universe_id_and_deleted_at" ON "deities" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "floras" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "aliases" varchar DEFAULT NULL, "order" varchar DEFAULT NULL, "family" varchar DEFAULT NULL, "genus" varchar DEFAULT NULL, "colorings" varchar DEFAULT NULL, "size" varchar DEFAULT NULL, "smell" varchar DEFAULT NULL, "taste" varchar DEFAULT NULL, "fruits" varchar DEFAULT NULL, "seeds" varchar DEFAULT NULL, "nuts" varchar DEFAULT NULL, "berries" varchar DEFAULT NULL, "medicinal_purposes" varchar DEFAULT NULL, "reproduction" varchar DEFAULT NULL, "seasonality" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "material_uses" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Flora', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_f1a58151e3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_95a1a881c7"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_floras_on_user_id" ON "floras" ("user_id");
CREATE INDEX "index_floras_on_universe_id" ON "floras" ("universe_id");
CREATE INDEX "index_floras_on_deleted_at" ON "floras" ("deleted_at");
CREATE INDEX "index_floras_on_deleted_at_and_id" ON "floras" ("deleted_at", "id");
CREATE INDEX "index_floras_on_deleted_at_and_user_id" ON "floras" ("deleted_at", "user_id");
CREATE INDEX "index_floras_on_deleted_at_and_universe_id" ON "floras" ("deleted_at", "universe_id");
CREATE INDEX "index_floras_on_id_and_deleted_at" ON "floras" ("id", "deleted_at");
CREATE INDEX "index_floras_on_user_id_and_universe_id_and_deleted_at" ON "floras" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "foods" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Food', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_bd41194a6c"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_541e2e5c7b"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_foods_on_user_id" ON "foods" ("user_id");
CREATE INDEX "index_foods_on_universe_id" ON "foods" ("universe_id");
CREATE INDEX "index_foods_on_user_id_and_universe_id_and_deleted_at" ON "foods" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "governments" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "type_of_government" varchar DEFAULT NULL, "power_structure" varchar DEFAULT NULL, "power_source" varchar DEFAULT NULL, "checks_and_balances" varchar DEFAULT NULL, "sociopolitical" varchar DEFAULT NULL, "socioeconomical" varchar DEFAULT NULL, "geocultural" varchar DEFAULT NULL, "laws" varchar DEFAULT NULL, "immigration" varchar DEFAULT NULL, "privacy_ideologies" varchar DEFAULT NULL, "electoral_process" varchar DEFAULT NULL, "term_lengths" varchar DEFAULT NULL, "criminal_system" varchar DEFAULT NULL, "approval_ratings" varchar DEFAULT NULL, "military" varchar DEFAULT NULL, "navy" varchar DEFAULT NULL, "airforce" varchar DEFAULT NULL, "space_program" varchar DEFAULT NULL, "international_relations" varchar DEFAULT NULL, "civilian_life" varchar DEFAULT NULL, "founding_story" varchar DEFAULT NULL, "flag_design_story" varchar DEFAULT NULL, "notable_wars" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "page_type" varchar DEFAULT 'Government', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_2af454f50c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_002cf621b9"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_governments_on_user_id" ON "governments" ("user_id");
CREATE INDEX "index_governments_on_universe_id" ON "governments" ("universe_id");
CREATE INDEX "index_governments_on_deleted_at_and_id" ON "governments" ("deleted_at", "id");
CREATE INDEX "index_governments_on_deleted_at_and_user_id" ON "governments" ("deleted_at", "user_id");
CREATE INDEX "index_governments_on_deleted_at_and_universe_id" ON "governments" ("deleted_at", "universe_id");
CREATE INDEX "index_governments_on_id_and_deleted_at" ON "governments" ("id", "deleted_at");
CREATE INDEX "index_governments_on_user_id_and_universe_id_and_deleted_at" ON "governments" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "groups" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "organization_structure" varchar DEFAULT NULL, "motivation" varchar DEFAULT NULL, "goal" varchar DEFAULT NULL, "obstacles" varchar DEFAULT NULL, "risks" varchar DEFAULT NULL, "inventory" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Group', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_groups_on_deleted_at" ON "groups" ("deleted_at");
CREATE INDEX "index_groups_on_user_id" ON "groups" ("user_id");
CREATE INDEX "index_groups_on_universe_id" ON "groups" ("universe_id");
CREATE INDEX "index_groups_on_deleted_at_and_id" ON "groups" ("deleted_at", "id");
CREATE INDEX "index_groups_on_deleted_at_and_user_id" ON "groups" ("deleted_at", "user_id");
CREATE INDEX "index_groups_on_deleted_at_and_universe_id" ON "groups" ("deleted_at", "universe_id");
CREATE INDEX "index_groups_on_id_and_deleted_at" ON "groups" ("id", "deleted_at");
CREATE INDEX "index_groups_on_user_id_and_universe_id_and_deleted_at" ON "groups" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "jobs" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Job', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_5daaa2f440"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_df6238c8a6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_jobs_on_user_id" ON "jobs" ("user_id");
CREATE INDEX "index_jobs_on_universe_id" ON "jobs" ("universe_id");
CREATE INDEX "index_jobs_on_user_id_and_universe_id_and_deleted_at" ON "jobs" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "landmarks" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "size" varchar DEFAULT NULL, "materials" varchar DEFAULT NULL, "colors" varchar DEFAULT NULL, "creation_story" varchar DEFAULT NULL, "established_year" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "page_type" varchar DEFAULT 'Landmark', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_03743e2c36"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_7aff9f0a17"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_landmarks_on_universe_id" ON "landmarks" ("universe_id");
CREATE INDEX "index_landmarks_on_user_id" ON "landmarks" ("user_id");
CREATE INDEX "index_landmarks_on_deleted_at_and_id" ON "landmarks" ("deleted_at", "id");
CREATE INDEX "index_landmarks_on_deleted_at_and_user_id" ON "landmarks" ("deleted_at", "user_id");
CREATE INDEX "index_landmarks_on_deleted_at_and_universe_id" ON "landmarks" ("deleted_at", "universe_id");
CREATE INDEX "index_landmarks_on_id_and_deleted_at" ON "landmarks" ("id", "deleted_at");
CREATE INDEX "index_landmarks_on_user_id_and_universe_id_and_deleted_at" ON "landmarks" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "languages" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "history" varchar DEFAULT NULL, "typology" varchar DEFAULT NULL, "dialectical_information" varchar DEFAULT NULL, "register" varchar DEFAULT NULL, "phonology" varchar DEFAULT NULL, "grammar" varchar DEFAULT NULL, "numbers" varchar DEFAULT NULL, "quantifiers" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Language', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_languages_on_deleted_at" ON "languages" ("deleted_at");
CREATE INDEX "index_languages_on_user_id" ON "languages" ("user_id");
CREATE INDEX "index_languages_on_universe_id" ON "languages" ("universe_id");
CREATE INDEX "index_languages_on_deleted_at_and_id" ON "languages" ("deleted_at", "id");
CREATE INDEX "index_languages_on_deleted_at_and_user_id" ON "languages" ("deleted_at", "user_id");
CREATE INDEX "index_languages_on_deleted_at_and_universe_id" ON "languages" ("deleted_at", "universe_id");
CREATE INDEX "index_languages_on_id_and_deleted_at" ON "languages" ("id", "deleted_at");
CREATE INDEX "index_languages_on_user_id_and_universe_id_and_deleted_at" ON "languages" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "magics" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "type_of" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "visuals" varchar DEFAULT NULL, "effects" varchar DEFAULT NULL, "positive_effects" varchar DEFAULT NULL, "negative_effects" varchar DEFAULT NULL, "neutral_effects" varchar DEFAULT NULL, "element" varchar DEFAULT NULL, "resource_costs" varchar DEFAULT NULL, "materials" varchar DEFAULT NULL, "skills_required" varchar DEFAULT NULL, "limitations" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Magic', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_magics_on_deleted_at" ON "magics" ("deleted_at");
CREATE INDEX "index_magics_on_user_id" ON "magics" ("user_id");
CREATE INDEX "index_magics_on_universe_id" ON "magics" ("universe_id");
CREATE INDEX "index_magics_on_deleted_at_and_id" ON "magics" ("deleted_at", "id");
CREATE INDEX "index_magics_on_deleted_at_and_user_id" ON "magics" ("deleted_at", "user_id");
CREATE INDEX "index_magics_on_deleted_at_and_universe_id" ON "magics" ("deleted_at", "universe_id");
CREATE INDEX "index_magics_on_id_and_deleted_at" ON "magics" ("id", "deleted_at");
CREATE INDEX "index_magics_on_user_id_and_universe_id_and_deleted_at" ON "magics" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "planets" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "size" varchar DEFAULT NULL, "surface" varchar DEFAULT NULL, "climate" varchar DEFAULT NULL, "weather" varchar DEFAULT NULL, "water_content" varchar DEFAULT NULL, "natural_resources" varchar DEFAULT NULL, "length_of_day" varchar DEFAULT NULL, "length_of_night" varchar DEFAULT NULL, "calendar_system" varchar DEFAULT NULL, "population" varchar DEFAULT NULL, "moons" varchar DEFAULT NULL, "orbit" varchar DEFAULT NULL, "visible_constellations" varchar DEFAULT NULL, "first_inhabitants_story" varchar DEFAULT NULL, "world_history" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "notes" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Planet', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_330aabdc9f"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_952c10b554"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_planets_on_universe_id" ON "planets" ("universe_id");
CREATE INDEX "index_planets_on_user_id" ON "planets" ("user_id");
CREATE INDEX "index_planets_on_deleted_at_and_id" ON "planets" ("deleted_at", "id");
CREATE INDEX "index_planets_on_deleted_at_and_user_id" ON "planets" ("deleted_at", "user_id");
CREATE INDEX "index_planets_on_deleted_at_and_universe_id" ON "planets" ("deleted_at", "universe_id");
CREATE INDEX "index_planets_on_id_and_deleted_at" ON "planets" ("id", "deleted_at");
CREATE INDEX "index_planets_on_user_id_and_universe_id_and_deleted_at" ON "planets" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "races" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "body_shape" varchar DEFAULT NULL, "skin_colors" varchar DEFAULT NULL, "height" varchar DEFAULT NULL, "weight" varchar DEFAULT NULL, "notable_features" varchar DEFAULT NULL, "variance" varchar DEFAULT NULL, "clothing" varchar DEFAULT NULL, "strengths" varchar DEFAULT NULL, "weaknesses" varchar DEFAULT NULL, "traditions" varchar DEFAULT NULL, "beliefs" varchar DEFAULT NULL, "governments" varchar DEFAULT NULL, "technologies" varchar DEFAULT NULL, "occupations" varchar DEFAULT NULL, "economics" varchar DEFAULT NULL, "favorite_foods" varchar DEFAULT NULL, "notable_events" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Race', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_races_on_deleted_at" ON "races" ("deleted_at");
CREATE INDEX "index_races_on_deleted_at_and_id" ON "races" ("deleted_at", "id");
CREATE INDEX "index_races_on_deleted_at_and_user_id" ON "races" ("deleted_at", "user_id");
CREATE INDEX "index_races_on_deleted_at_and_universe_id" ON "races" ("deleted_at", "universe_id");
CREATE INDEX "index_races_on_id_and_deleted_at" ON "races" ("id", "deleted_at");
CREATE INDEX "index_races_on_user_id_and_universe_id_and_deleted_at" ON "races" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "religions" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "origin_story" varchar DEFAULT NULL, "teachings" varchar DEFAULT NULL, "prophecies" varchar DEFAULT NULL, "places_of_worship" varchar DEFAULT NULL, "worship_services" varchar DEFAULT NULL, "obligations" varchar DEFAULT NULL, "paradise" varchar DEFAULT NULL, "initiation" varchar DEFAULT NULL, "rituals" varchar DEFAULT NULL, "holidays" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Religion', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_religions_on_deleted_at" ON "religions" ("deleted_at");
CREATE INDEX "index_religions_on_user_id" ON "religions" ("user_id");
CREATE INDEX "index_religions_on_universe_id" ON "religions" ("universe_id");
CREATE INDEX "index_religions_on_deleted_at_and_id" ON "religions" ("deleted_at", "id");
CREATE INDEX "index_religions_on_deleted_at_and_user_id" ON "religions" ("deleted_at", "user_id");
CREATE INDEX "index_religions_on_deleted_at_and_universe_id" ON "religions" ("deleted_at", "universe_id");
CREATE INDEX "index_religions_on_id_and_deleted_at" ON "religions" ("id", "deleted_at");
CREATE INDEX "index_religions_on_user_id_and_universe_id_and_deleted_at" ON "religions" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "scenes" ("id" integer NOT NULL PRIMARY KEY, "scene_number" integer DEFAULT NULL, "name" varchar DEFAULT NULL, "summary" varchar DEFAULT NULL, "universe_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "cause" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "results" varchar DEFAULT NULL, "prose" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "privacy" varchar DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "page_type" varchar DEFAULT 'Scene', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1);
CREATE INDEX "index_scenes_on_deleted_at" ON "scenes" ("deleted_at");
CREATE INDEX "index_scenes_on_user_id" ON "scenes" ("user_id");
CREATE INDEX "index_scenes_on_universe_id" ON "scenes" ("universe_id");
CREATE INDEX "index_scenes_on_deleted_at_and_id" ON "scenes" ("deleted_at", "id");
CREATE INDEX "index_scenes_on_deleted_at_and_user_id" ON "scenes" ("deleted_at", "user_id");
CREATE INDEX "index_scenes_on_deleted_at_and_universe_id" ON "scenes" ("deleted_at", "universe_id");
CREATE INDEX "index_scenes_on_id_and_deleted_at" ON "scenes" ("id", "deleted_at");
CREATE INDEX "index_scenes_on_user_id_and_universe_id_and_deleted_at" ON "scenes" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "schools" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'School', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_090b2e9e0c"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_a4d5e4f7c9"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_schools_on_user_id" ON "schools" ("user_id");
CREATE INDEX "index_schools_on_universe_id" ON "schools" ("universe_id");
CREATE INDEX "index_schools_on_user_id_and_universe_id_and_deleted_at" ON "schools" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "sports" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Sport', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_cb23113021"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_77c46d51a4"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_sports_on_user_id" ON "sports" ("user_id");
CREATE INDEX "index_sports_on_universe_id" ON "sports" ("universe_id");
CREATE INDEX "index_sports_on_user_id_and_universe_id_and_deleted_at" ON "sports" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "technologies" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "materials" varchar DEFAULT NULL, "manufacturing_process" varchar DEFAULT NULL, "sales_process" varchar DEFAULT NULL, "cost" varchar DEFAULT NULL, "rarity" varchar DEFAULT NULL, "purpose" varchar DEFAULT NULL, "how_it_works" varchar DEFAULT NULL, "resources_used" varchar DEFAULT NULL, "physical_description" varchar DEFAULT NULL, "size" varchar DEFAULT NULL, "weight" varchar DEFAULT NULL, "colors" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "page_type" varchar DEFAULT 'Technology', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_5ab747cff4"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_ca943d1cf9"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
);
CREATE INDEX "index_technologies_on_user_id" ON "technologies" ("user_id");
CREATE INDEX "index_technologies_on_universe_id" ON "technologies" ("universe_id");
CREATE INDEX "index_technologies_on_deleted_at_and_id" ON "technologies" ("deleted_at", "id");
CREATE INDEX "index_technologies_on_deleted_at_and_user_id" ON "technologies" ("deleted_at", "user_id");
CREATE INDEX "index_technologies_on_deleted_at_and_universe_id" ON "technologies" ("deleted_at", "universe_id");
CREATE INDEX "index_technologies_on_id_and_deleted_at" ON "technologies" ("id", "deleted_at");
CREATE INDEX "index_technologies_on_user_id_and_universe_id_and_deleted_at" ON "technologies" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "towns" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "laws" varchar DEFAULT NULL, "sports" varchar DEFAULT NULL, "politics" varchar DEFAULT NULL, "founding_story" varchar DEFAULT NULL, "established_year" varchar DEFAULT NULL, "notes" varchar DEFAULT NULL, "private_notes" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "page_type" varchar DEFAULT 'Town', "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_f4280f419b"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_7a26901707"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_towns_on_universe_id" ON "towns" ("universe_id");
CREATE INDEX "index_towns_on_user_id" ON "towns" ("user_id");
CREATE INDEX "index_towns_on_deleted_at_and_id" ON "towns" ("deleted_at", "id");
CREATE INDEX "index_towns_on_deleted_at_and_user_id" ON "towns" ("deleted_at", "user_id");
CREATE INDEX "index_towns_on_deleted_at_and_universe_id" ON "towns" ("deleted_at", "universe_id");
CREATE INDEX "index_towns_on_id_and_deleted_at" ON "towns" ("id", "deleted_at");
CREATE INDEX "index_towns_on_user_id_and_universe_id_and_deleted_at" ON "towns" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "traditions" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Tradition', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_5d8625161a"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_504f97e712"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_traditions_on_user_id" ON "traditions" ("user_id");
CREATE INDEX "index_traditions_on_universe_id" ON "traditions" ("universe_id");
CREATE INDEX "index_traditions_on_user_id_and_universe_id_and_deleted_at" ON "traditions" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "vehicles" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "user_id" integer DEFAULT NULL, "universe_id" integer DEFAULT NULL, "deleted_at" datetime DEFAULT NULL, "privacy" varchar DEFAULT NULL, "page_type" varchar DEFAULT 'Vehicle', "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "archived_at" datetime DEFAULT NULL, "favorite" boolean DEFAULT NULL, "columns_migrated_from_old_style" boolean DEFAULT 1, CONSTRAINT "fk_rails_8564701168"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_9e34682d54"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_vehicles_on_user_id" ON "vehicles" ("user_id");
CREATE INDEX "index_vehicles_on_universe_id" ON "vehicles" ("universe_id");
CREATE INDEX "index_vehicles_on_user_id_and_universe_id_and_deleted_at" ON "vehicles" ("user_id", "universe_id", "deleted_at");
CREATE TABLE IF NOT EXISTS "notifications" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "message_html" varchar DEFAULT NULL, "icon" varchar DEFAULT 'notifications_active', "happened_at" datetime DEFAULT NULL, "viewed_at" datetime DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "icon_color" varchar DEFAULT 'blue', "passthrough_link" varchar, "reference_code" varchar);
CREATE INDEX "index_notifications_on_user_id" ON "notifications" ("user_id");
CREATE TABLE IF NOT EXISTS "content_page_shares" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "content_page_type" varchar, "content_page_id" integer, "shared_at" datetime, "privacy" varchar, "message" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "deleted_at" datetime, "secondary_content_page_type" varchar, "secondary_content_page_id" integer, CONSTRAINT "fk_rails_9a20edea42"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_content_page_shares_on_user_id" ON "content_page_shares" ("user_id");
CREATE INDEX "cps_index" ON "content_page_shares" ("content_page_type", "content_page_id");
CREATE TABLE IF NOT EXISTS "share_comments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "content_page_share_id" integer NOT NULL, "message" varchar, "deleted_at" datetime, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_5ffd66f029"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_1d74ef3ca4"
FOREIGN KEY ("content_page_share_id")
  REFERENCES "content_page_shares" ("id")
);
CREATE INDEX "index_share_comments_on_user_id" ON "share_comments" ("user_id");
CREATE INDEX "index_share_comments_on_content_page_share_id" ON "share_comments" ("content_page_share_id");
CREATE TABLE IF NOT EXISTS "content_page_share_followings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "content_page_share_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_61fe1fc3b1"
FOREIGN KEY ("content_page_share_id")
  REFERENCES "content_page_shares" ("id")
, CONSTRAINT "fk_rails_e94d4cf5ae"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_content_page_share_followings_on_content_page_share_id" ON "content_page_share_followings" ("content_page_share_id");
CREATE INDEX "index_content_page_share_followings_on_user_id" ON "content_page_share_followings" ("user_id");
CREATE TABLE IF NOT EXISTS "page_collections" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar, "subtitle" varchar, "user_id" integer NOT NULL, "privacy" varchar, "page_types" varchar, "color" varchar, "cover_image" varchar, "auto_accept" boolean DEFAULT 0, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "description" varchar, "allow_submissions" boolean, "slug" varchar, "deleted_at" datetime, CONSTRAINT "fk_rails_7ba7f2e743"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_page_collections_on_user_id" ON "page_collections" ("user_id");
CREATE TABLE IF NOT EXISTS "page_collection_submissions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "content_type" varchar NOT NULL, "content_id" integer NOT NULL, "user_id" integer NOT NULL, "accepted_at" datetime, "submitted_at" datetime, "page_collection_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "explanation" varchar, "cached_content_name" varchar, "deleted_at" datetime, CONSTRAINT "fk_rails_1e4fd04022"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "polycontent_collection_index" ON "page_collection_submissions" ("content_type", "content_id");
CREATE INDEX "index_page_collection_submissions_on_user_id" ON "page_collection_submissions" ("user_id");
CREATE INDEX "index_page_collection_submissions_on_page_collection_id" ON "page_collection_submissions" ("page_collection_id");
CREATE TABLE IF NOT EXISTS "content_page_share_reports" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "content_page_share_id" integer NOT NULL, "user_id" integer NOT NULL, "approved_at" datetime, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_6907fc061f"
FOREIGN KEY ("content_page_share_id")
  REFERENCES "content_page_shares" ("id")
, CONSTRAINT "fk_rails_ace0d9d5b5"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_content_page_share_reports_on_content_page_share_id" ON "content_page_share_reports" ("content_page_share_id");
CREATE INDEX "index_content_page_share_reports_on_user_id" ON "content_page_share_reports" ("user_id");
CREATE TABLE IF NOT EXISTS "users" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "email" varchar NOT NULL, "old_password" varchar DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar DEFAULT NULL, "reset_password_sent_at" datetime DEFAULT NULL, "remember_created_at" datetime DEFAULT NULL, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime DEFAULT NULL, "last_sign_in_at" datetime DEFAULT NULL, "current_sign_in_ip" varchar DEFAULT NULL, "last_sign_in_ip" varchar DEFAULT NULL, "plan_type" varchar DEFAULT NULL, "stripe_customer_id" varchar DEFAULT NULL, "email_updates" boolean DEFAULT 1, "selected_billing_plan_id" integer DEFAULT NULL, "upload_bandwidth_kb" integer DEFAULT 50000, "secure_code" varchar DEFAULT NULL, "fluid_preference" boolean DEFAULT NULL, "username" varchar DEFAULT NULL, "forum_administrator" boolean DEFAULT 0 NOT NULL, "deleted_at" datetime DEFAULT NULL, "site_administrator" boolean DEFAULT 0, "forum_moderator" boolean DEFAULT 0, "bio" varchar DEFAULT NULL, "favorite_author" varchar DEFAULT NULL, "favorite_genre" varchar DEFAULT NULL, "location" varchar DEFAULT NULL, "age" varchar DEFAULT NULL, "gender" varchar DEFAULT NULL, "interests" varchar DEFAULT NULL, "forums_badge_text" varchar DEFAULT NULL, "keyboard_shortcuts_preference" boolean DEFAULT NULL, "favorite_book" varchar DEFAULT NULL, "website" varchar DEFAULT NULL, "inspirations" varchar DEFAULT NULL, "other_names" varchar DEFAULT NULL, "favorite_quote" varchar DEFAULT NULL, "occupation" varchar DEFAULT NULL, "favorite_page_type" varchar DEFAULT NULL, "dark_mode_enabled" boolean DEFAULT NULL, "notification_updates" boolean DEFAULT 1, "community_features_enabled" boolean DEFAULT 1, "private_profile" boolean DEFAULT 0, "enabled_april_fools" boolean);
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE INDEX "index_users_on_deleted_at" ON "users" ("deleted_at");
CREATE INDEX "index_users_on_deleted_at_and_username" ON "users" ("deleted_at", "username");
CREATE INDEX "index_users_on_id_and_deleted_at" ON "users" ("id", "deleted_at");
CREATE TABLE IF NOT EXISTS "timelines" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "universe_id" integer, "user_id" integer NOT NULL, "page_type" varchar DEFAULT 'Timeline', "deleted_at" datetime, "archived_at" datetime, "privacy" varchar DEFAULT 'private', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "description" varchar, "subtitle" varchar, "notes" varchar, "private_notes" varchar, "favorite" boolean, CONSTRAINT "fk_rails_511056e8f8"
FOREIGN KEY ("universe_id")
  REFERENCES "universes" ("id")
, CONSTRAINT "fk_rails_390503c955"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_timelines_on_universe_id" ON "timelines" ("universe_id");
CREATE INDEX "index_timelines_on_user_id" ON "timelines" ("user_id");
CREATE TABLE IF NOT EXISTS "timeline_events" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "timeline_id" integer NOT NULL, "time_label" varchar, "title" varchar, "description" varchar, "notes" varchar, "position" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "deleted_at" datetime, CONSTRAINT "fk_rails_1712b6a5c9"
FOREIGN KEY ("timeline_id")
  REFERENCES "timelines" ("id")
);
CREATE INDEX "index_timeline_events_on_timeline_id" ON "timeline_events" ("timeline_id");
CREATE TABLE IF NOT EXISTS "timeline_event_entities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "entity_type" varchar NOT NULL, "entity_id" integer NOT NULL, "timeline_event_id" integer NOT NULL, "notes" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_a5a64dc4ba"
FOREIGN KEY ("timeline_event_id")
  REFERENCES "timeline_events" ("id")
);
CREATE INDEX "index_timeline_event_entities_on_entity_type_and_entity_id" ON "timeline_event_entities" ("entity_type", "entity_id");
CREATE INDEX "index_timeline_event_entities_on_timeline_event_id" ON "timeline_event_entities" ("timeline_event_id");
CREATE INDEX "index_secondary_content_page_share" ON "content_page_shares" ("secondary_content_page_type", "secondary_content_page_id");
CREATE TABLE IF NOT EXISTS "page_collection_followings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "page_collection_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b59b0cf765"
FOREIGN KEY ("page_collection_id")
  REFERENCES "page_collections" ("id")
, CONSTRAINT "fk_rails_0bee32acfe"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_page_collection_followings_on_page_collection_id" ON "page_collection_followings" ("page_collection_id");
CREATE INDEX "index_page_collection_followings_on_user_id" ON "page_collection_followings" ("user_id");
CREATE TABLE IF NOT EXISTS "page_collection_reports" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "page_collection_id" integer NOT NULL, "user_id" integer NOT NULL, "approved_at" datetime, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_bb76d8c681"
FOREIGN KEY ("page_collection_id")
  REFERENCES "page_collections" ("id")
, CONSTRAINT "fk_rails_07c96d3006"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_page_collection_reports_on_page_collection_id" ON "page_collection_reports" ("page_collection_id");
CREATE INDEX "index_page_collection_reports_on_user_id" ON "page_collection_reports" ("user_id");
CREATE TABLE IF NOT EXISTS "application_integrations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "name" varchar, "description" varchar, "organization_name" varchar, "organization_url" varchar, "website_url" varchar, "privacy_policy_url" varchar, "token" varchar, "last_used_at" datetime, "authorization_callback_url" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "event_ping_url" varchar, "application_token" varchar, CONSTRAINT "fk_rails_0b36232f0d"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_application_integrations_on_user_id" ON "application_integrations" ("user_id");
CREATE TABLE IF NOT EXISTS "integration_authorizations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "application_integration_id" integer NOT NULL, "referral_url" varchar, "ip_address" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "origin" varchar, "content_type" varchar, "user_agent" varchar, "user_token" varchar, CONSTRAINT "fk_rails_d43dae98c5"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_9025d4b7d9"
FOREIGN KEY ("application_integration_id")
  REFERENCES "application_integrations" ("id")
);
CREATE INDEX "index_integration_authorizations_on_user_id" ON "integration_authorizations" ("user_id");
CREATE INDEX "index_integration_authorizations_on_application_integration_id" ON "integration_authorizations" ("application_integration_id");
CREATE TABLE IF NOT EXISTS "api_requests" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "application_integration_id" integer, "integration_authorization_id" integer, "result" varchar, "updates_used" integer DEFAULT 0, "ip_address" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_53223486c1"
FOREIGN KEY ("application_integration_id")
  REFERENCES "application_integrations" ("id")
, CONSTRAINT "fk_rails_7a8f873624"
FOREIGN KEY ("integration_authorization_id")
  REFERENCES "integration_authorizations" ("id")
);
CREATE INDEX "index_api_requests_on_application_integration_id" ON "api_requests" ("application_integration_id");
CREATE INDEX "index_api_requests_on_integration_authorization_id" ON "api_requests" ("integration_authorization_id");
CREATE TABLE IF NOT EXISTS "document_revisions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "document_id" integer NOT NULL, "title" varchar, "body" varchar, "synopsis" varchar, "universe_id" integer, "notes_text" varchar, "deleted_at" datetime, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_35622b6831"
FOREIGN KEY ("document_id")
  REFERENCES "documents" ("id")
);
CREATE INDEX "index_document_revisions_on_document_id" ON "document_revisions" ("document_id");
CREATE TABLE IF NOT EXISTS "end_of_day_analytics_reports" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "day" date, "user_signups" integer, "new_monthly_subscriptions" integer, "ended_monthly_subscriptions" integer, "new_trimonthly_subscriptions" integer, "ended_trimonthly_subscriptions" integer, "new_annual_subscriptions" integer, "ended_annual_subscriptions" integer, "paid_paypal_invoices" integer, "buildings_created" integer, "characters_created" integer, "conditions_created" integer, "continents_created" integer, "countries_created" integer, "creatures_created" integer, "deities_created" integer, "floras_created" integer, "foods_created" integer, "governments_created" integer, "groups_created" integer, "items_created" integer, "jobs_created" integer, "landmarks_created" integer, "languages_created" integer, "locations_created" integer, "lores_created" integer, "magics_created" integer, "planets_created" integer, "races_created" integer, "religions_created" integer, "scenes_created" integer, "schools_created" integer, "sports_created" integer, "technologies_created" integer, "towns_created" integer, "traditions_created" integer, "universes_created" integer, "vehicles_created" integer, "documents_created" integer, "documents_edited" integer, "timelines_created" integer, "stream_shares_created" integer, "stream_comments" integer, "collections_created" integer, "collection_submissions_created" integer, "thredded_threads_created" integer, "thredded_replies_created" integer, "thredded_private_messages_created" integer, "thredded_private_replies_created" integer, "document_analyses_created" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "document_analyses" ("id" integer NOT NULL PRIMARY KEY, "document_id" integer DEFAULT NULL, "word_count" integer DEFAULT NULL, "page_count" integer DEFAULT NULL, "paragraph_count" integer DEFAULT NULL, "character_count" integer DEFAULT NULL, "sentence_count" integer DEFAULT NULL, "readability_score" integer DEFAULT NULL, "combined_average_reading_level" float DEFAULT NULL, "flesch_kincaid_grade_level" integer DEFAULT NULL, "flesch_kincaid_age_minimum" integer DEFAULT NULL, "flesch_kincaid_reading_ease" float DEFAULT NULL, "forcast_grade_level" float DEFAULT NULL, "coleman_liau_index" float DEFAULT NULL, "automated_readability_index" float DEFAULT NULL, "gunning_fog_index" float DEFAULT NULL, "smog_grade" float DEFAULT NULL, "adjective_count" integer DEFAULT NULL, "noun_count" integer DEFAULT NULL, "verb_count" integer DEFAULT NULL, "pronoun_count" integer DEFAULT NULL, "preposition_count" integer DEFAULT NULL, "conjunction_count" integer DEFAULT NULL, "adverb_count" integer DEFAULT NULL, "determiner_count" integer DEFAULT NULL, "n_syllable_words" json DEFAULT NULL, "words_used_once_count" integer DEFAULT NULL, "words_used_repeatedly_count" integer DEFAULT NULL, "simple_words_count" integer DEFAULT NULL, "complex_words_count" integer DEFAULT NULL, "sentiment_score" float DEFAULT NULL, "sentiment_label" varchar DEFAULT NULL, "language" varchar DEFAULT NULL, "sadness_score" float DEFAULT NULL, "joy_score" float DEFAULT NULL, "fear_score" float DEFAULT NULL, "disgust_score" float DEFAULT NULL, "anger_score" float DEFAULT NULL, "words_per_sentence" json DEFAULT NULL, "completed_at" datetime DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "progress" integer DEFAULT 0, "interrogative_count" integer DEFAULT NULL, "proper_noun_count" integer DEFAULT NULL, "queued_at" datetime DEFAULT NULL, "linsear_write_grade" float DEFAULT NULL, "dale_chall_grade" float DEFAULT NULL, "unique_complex_words_count" integer DEFAULT NULL, "unique_simple_words_count" integer DEFAULT NULL, "hate_content_flag" boolean DEFAULT 0, "hate_trigger_words" varchar DEFAULT NULL, "profanity_content_flag" boolean DEFAULT 0, "profanity_trigger_words" varchar DEFAULT NULL, "sex_content_flag" boolean DEFAULT 0, "sex_trigger_words" varchar DEFAULT NULL, "violence_content_flag" boolean DEFAULT 0, "violence_trigger_words" varchar DEFAULT NULL, "adult_content_flag" boolean DEFAULT 0, "most_used_words" json, "most_used_adjectives" json, "most_used_nouns" json, "most_used_verbs" json, "most_used_adverbs" json, CONSTRAINT "fk_rails_a7695db5e5"
FOREIGN KEY ("document_id")
  REFERENCES "documents" ("id")
);
CREATE INDEX "index_document_analyses_on_document_id" ON "document_analyses" ("document_id");
CREATE TABLE IF NOT EXISTS "building_towns" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "town_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "building_countries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "country_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "building_landmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "landmark_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "building_locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "location_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "building_nearby_buildings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "nearby_building_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "building_schools" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "building_id" integer, "district_school_id" integer, "user_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE INDEX "index_documents_on_user_id_and_deleted_at" ON "documents" ("user_id", "deleted_at");
CREATE INDEX "index_thredded_topics_on_deleted_at" ON "thredded_topics" ("deleted_at");
CREATE INDEX "index_thredded_topics_on_deleted_at_and_messageboard_id" ON "thredded_topics" ("deleted_at", "messageboard_id");
CREATE INDEX "index_thredded_topics_on_deleted_at_and_user_id" ON "thredded_topics" ("deleted_at", "user_id");
CREATE TABLE IF NOT EXISTS "attribute_fields" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "attribute_category_id" integer NOT NULL, "name" varchar NOT NULL, "label" varchar NOT NULL, "field_type" varchar NOT NULL, "description" text DEFAULT NULL, "privacy" varchar DEFAULT 'public' NOT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "hidden" boolean DEFAULT 0, "deleted_at" datetime DEFAULT NULL, "old_column_source" varchar DEFAULT NULL, "position" integer DEFAULT NULL, "field_options" json DEFAULT NULL, "migrated_from_legacy" boolean DEFAULT 0);
CREATE INDEX "index_attribute_fields_on_user_id_and_name" ON "attribute_fields" ("user_id", "name");
CREATE INDEX "index_attribute_fields_on_user_id" ON "attribute_fields" ("user_id");
CREATE INDEX "index_attribute_fields_on_user_id_and_attribute_category_id" ON "attribute_fields" ("user_id", "attribute_category_id");
CREATE INDEX "index_attribute_fields_on_user_id_and_field_type" ON "attribute_fields" ("user_id", "field_type");
CREATE INDEX "index_attribute_fields_on_user_id_and_old_column_source" ON "attribute_fields" ("user_id", "old_column_source");
CREATE INDEX "deleted_at__attribute_category_id" ON "attribute_fields" ("deleted_at", "attribute_category_id");
CREATE INDEX "index_attribute_fields_on_deleted_at_and_name" ON "attribute_fields" ("deleted_at", "name");
CREATE INDEX "field_lookup_by_label_index" ON "attribute_fields" ("user_id", "attribute_category_id", "label", "hidden", "deleted_at");
CREATE INDEX "special_field_type_index" ON "attribute_fields" ("user_id", "attribute_category_id", "field_type", "deleted_at");
CREATE INDEX "temporary_migration_lookup_index" ON "attribute_fields" ("user_id", "attribute_category_id", "label", "old_column_source", "field_type");
CREATE INDEX "temporary_migration_lookup_with_deleted_index" ON "attribute_fields" ("user_id", "attribute_category_id", "label", "old_column_source", "field_type", "deleted_at");
CREATE INDEX "attribute_fields_aci_label_ocs_ui_ft" ON "attribute_fields" ("attribute_category_id", "label", "old_column_source", "user_id", "field_type");
CREATE INDEX "attribute_fields_aci_label_ocs_ft" ON "attribute_fields" ("attribute_category_id", "label", "old_column_source", "field_type");
CREATE INDEX "attribute_fields_da_ui_aci_l_h" ON "attribute_fields" ("deleted_at", "user_id", "attribute_category_id", "label", "hidden");
CREATE INDEX "index_attribute_fields_on_attribute_category_id_and_deleted_at" ON "attribute_fields" ("attribute_category_id", "deleted_at");
CREATE INDEX "attribute_fields_aci_ocs_ui_ft" ON "attribute_fields" ("attribute_category_id", "old_column_source", "user_id", "field_type");
CREATE INDEX "index_attribute_fields_on_deleted_at_and_position" ON "attribute_fields" ("deleted_at", "position");
CREATE TABLE IF NOT EXISTS "page_references" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "referencing_page_type" varchar NOT NULL, "referencing_page_id" integer NOT NULL, "referenced_page_type" varchar NOT NULL, "referenced_page_id" integer NOT NULL, "attribute_field_id" integer, "cached_relation_title" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "reference_type" varchar, CONSTRAINT "fk_rails_b0279f99bd"
FOREIGN KEY ("attribute_field_id")
  REFERENCES "attribute_fields" ("id")
);
CREATE INDEX "page_reference_referencing_page" ON "page_references" ("referencing_page_type", "referencing_page_id");
CREATE INDEX "page_reference_referenced_page" ON "page_references" ("referenced_page_type", "referenced_page_id");
CREATE INDEX "index_page_references_on_attribute_field_id" ON "page_references" ("attribute_field_id");
CREATE INDEX "index_timelines_on_deleted_at_and_user_id" ON "timelines" ("deleted_at", "user_id");
CREATE INDEX "index_documents_on_deleted_at_and_universe_id" ON "documents" ("deleted_at", "universe_id");
CREATE INDEX "index_documents_on_deleted_at_and_universe_id_and_user_id" ON "documents" ("deleted_at", "universe_id", "user_id");
CREATE TABLE IF NOT EXISTS "thredded_posts" ("id" integer NOT NULL PRIMARY KEY, "user_id" integer DEFAULT NULL, "content" text(65535) DEFAULT NULL, "source" varchar(191) DEFAULT 'web', "postable_id" integer NOT NULL, "messageboard_id" integer NOT NULL, "moderation_state" integer NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime DEFAULT NULL);
CREATE INDEX "index_thredded_posts_for_display" ON "thredded_posts" ("moderation_state", "updated_at");
CREATE INDEX "index_thredded_posts_on_messageboard_id" ON "thredded_posts" ("messageboard_id");
CREATE INDEX "index_thredded_posts_on_postable_id" ON "thredded_posts" ("postable_id");
CREATE INDEX "index_thredded_posts_on_postable_id_and_postable_type" ON "thredded_posts" ("postable_id");
CREATE INDEX "index_thredded_posts_on_user_id" ON "thredded_posts" ("user_id");
CREATE INDEX "index_thredded_posts_on_deleted_at" ON "thredded_posts" ("deleted_at");
CREATE INDEX "index_thredded_posts_on_deleted_at_and_messageboard_id" ON "thredded_posts" ("deleted_at", "messageboard_id");
CREATE INDEX "index_thredded_posts_on_deleted_at_and_postable_id" ON "thredded_posts" ("deleted_at", "postable_id");
CREATE INDEX "index_thredded_posts_on_deleted_at_and_user_id" ON "thredded_posts" ("deleted_at", "user_id");
INSERT INTO "schema_migrations" (version) VALUES
('20140713043535'),
('20150419134141'),
('20160405035806'),
('20160429190058'),
('20160503180503'),
('20160503183859'),
('20160503192938'),
('20160503193513'),
('20160503193541'),
('20160503201328'),
('20160503205001'),
('20160806064053'),
('20160903220122'),
('20160903221005'),
('20160903221349'),
('20160903221819'),
('20160903222311'),
('20160903222537'),
('20160903223957'),
('20160920180129'),
('20160922204302'),
('20160922204317'),
('20161001232324'),
('20161003000856'),
('20161003183741'),
('20161005111959'),
('20161005115303'),
('20161005120615'),
('20161014204501'),
('20161014210509'),
('20161014220538'),
('20161014223701'),
('20161016211328'),
('20161016213335'),
('20161016220220'),
('20161016222100'),
('20161021103850'),
('20161021113013'),
('20161021114135'),
('20161021202915'),
('20161021211814'),
('20161021220223'),
('20161021225347'),
('20161021225944'),
('20161021230205'),
('20161021230419'),
('20161021230626'),
('20161024122250'),
('20161024123021'),
('20161024123040'),
('20161024123105'),
('20161024123140'),
('20161024123157'),
('20161024123208'),
('20161024123232'),
('20161024123248'),
('20161024123312'),
('20161024123325'),
('20161024123345'),
('20161024123400'),
('20161024195442'),
('20161024202657'),
('20161024204744'),
('20161024204806'),
('20161024204826'),
('20161029224240'),
('20161029224408'),
('20161029224502'),
('20161029224540'),
('20161029224631'),
('20161029224722'),
('20161102095042'),
('20161102182212'),
('20161102182259'),
('20170120213941'),
('20170120214443'),
('20170120214721'),
('20170127164644'),
('20170201151923'),
('20170216211714'),
('20170216211914'),
('20170218010814'),
('20170218022943'),
('20170228160245'),
('20170326164002'),
('20170326170148'),
('20170331001122'),
('20170403180417'),
('20170415183537'),
('20170415192410'),
('20170415192437'),
('20170417190318'),
('20170517152023'),
('20170517164648'),
('20170712190101'),
('20170724114620'),
('20170724114723'),
('20170724114833'),
('20170731000013'),
('20170731000608'),
('20170731001131'),
('20170731001803'),
('20170731004406'),
('20170731004450'),
('20170731004509'),
('20170731004712'),
('20170731010449'),
('20170811090735'),
('20170811145534'),
('20171028220829'),
('20171028221518'),
('20171028230258'),
('20171226195348'),
('20171226202223'),
('20171226202321'),
('20171226202730'),
('20171226202745'),
('20171226202810'),
('20171226203002'),
('20171226203016'),
('20171226203030'),
('20171226203042'),
('20171226203059'),
('20171226203117'),
('20171226203129'),
('20171226213749'),
('20171227180909'),
('20171231172750'),
('20171231174144'),
('20171231174241'),
('20171231175209'),
('20171231175633'),
('20171231175706'),
('20171231191101'),
('20171231191117'),
('20171231191133'),
('20171231201746'),
('20171231201817'),
('20171231201900'),
('20171231230411'),
('20171231230524'),
('20171231230530'),
('20171231230535'),
('20171231230540'),
('20171231230546'),
('20171231230551'),
('20171231230645'),
('20171231230650'),
('20171231230656'),
('20171231230701'),
('20171231230707'),
('20171231230712'),
('20171231230717'),
('20171231230751'),
('20171231230757'),
('20171231230802'),
('20171231235747'),
('20180107183433'),
('20180110200009'),
('20180112043008'),
('20180120010225'),
('20180120031750'),
('20180120032146'),
('20180120033402'),
('20180127055730'),
('20180127200709'),
('20180127200846'),
('20180127202120'),
('20180127203130'),
('20180129033131'),
('20180130231607'),
('20180130233224'),
('20180130233229'),
('20180130233235'),
('20180130233240'),
('20180130233245'),
('20180130233250'),
('20180130233256'),
('20180130233301'),
('20180130233306'),
('20180130233311'),
('20180130233316'),
('20180130233539'),
('20180130233841'),
('20180130233846'),
('20180130233851'),
('20180130233857'),
('20180130233902'),
('20180130233907'),
('20180130233912'),
('20180130233918'),
('20180130233923'),
('20180130233928'),
('20180130234318'),
('20180130234323'),
('20180130234329'),
('20180130234334'),
('20180130234339'),
('20180130234344'),
('20180130234349'),
('20180130234355'),
('20180130234400'),
('20180130234405'),
('20180130234410'),
('20180130234415'),
('20180130234420'),
('20180130234505'),
('20180130234511'),
('20180130234516'),
('20180130234521'),
('20180130234526'),
('20180130234531'),
('20180131055724'),
('20180131055729'),
('20180131055734'),
('20180131055739'),
('20180131055744'),
('20180131060014'),
('20180131061140'),
('20180131061146'),
('20180131061151'),
('20180131061726'),
('20180131061902'),
('20180131062407'),
('20180131062923'),
('20180131063312'),
('20180131063532'),
('20180131064051'),
('20180131064902'),
('20180202055802'),
('20180202055822'),
('20180202064238'),
('20180620012919'),
('20180715184447'),
('20180816163015'),
('20180816163038'),
('20180818213858'),
('20180824051228'),
('20180825000628'),
('20180910084049'),
('20180910090212'),
('20180917033731'),
('20180921182215'),
('20180924164517'),
('20180930063614'),
('20181002034500'),
('20181002170145'),
('20181017202825'),
('20181017205546'),
('20181017224014'),
('20181018182216'),
('20181030051214'),
('20181101205729'),
('20181101210336'),
('20181101210522'),
('20181101210714'),
('20181101210827'),
('20181101234459'),
('20190103211346'),
('20190109201055'),
('20190212220053'),
('20190216080611'),
('20190225004454'),
('20190227223759'),
('20190227224515'),
('20190227225006'),
('20190530025549'),
('20190530025713'),
('20190530025738'),
('20190530192249'),
('20190604162744'),
('20190613055406'),
('20190706073144'),
('20190706073303'),
('20190707182422'),
('20190731222334'),
('20190809173934'),
('20190813220011'),
('20190824040322'),
('20190824164634'),
('20190829222650'),
('20191017182040'),
('20191017182132'),
('20191017182144'),
('20191017182155'),
('20191017182206'),
('20191017182217'),
('20191017182229'),
('20191017182240'),
('20191017182251'),
('20191017182301'),
('20191017182312'),
('20191017182322'),
('20191017182332'),
('20191017182342'),
('20191017182352'),
('20191017182403'),
('20191017182424'),
('20191017182435'),
('20191017182447'),
('20191017182500'),
('20191017182513'),
('20191017182525'),
('20191017182536'),
('20191017182546'),
('20191017182558'),
('20191017182609'),
('20191017182623'),
('20191017191955'),
('20191113221411'),
('20191113234819'),
('20191214233333'),
('20191215054049'),
('20191215223411'),
('20191217224853'),
('20191217232203'),
('20200101072655'),
('20200103185508'),
('20200103190122'),
('20200110050855'),
('20200116062906'),
('20200116072334'),
('20200117224509'),
('20200122210737'),
('20200128161646'),
('20200128174509'),
('20200128231056'),
('20200128233630'),
('20200128234218'),
('20200128234553'),
('20200128235018'),
('20200128235332'),
('20200128235747'),
('20200128235859'),
('20200128235938'),
('20200129000008'),
('20200129000033'),
('20200129000115'),
('20200129000740'),
('20200129172155'),
('20200129180211'),
('20200129181300'),
('20200129220952'),
('20200130224044'),
('20200222051539'),
('20200302022930'),
('20200302223350'),
('20200302224753'),
('20200303002751'),
('20200325171712'),
('20200325191029'),
('20200325191416'),
('20200325191450'),
('20200325191522'),
('20200325191611'),
('20200325191721'),
('20200325191759'),
('20200325191904'),
('20200325192028'),
('20200325192109'),
('20200325192154'),
('20200325192225'),
('20200325192300'),
('20200325192355'),
('20200325192434'),
('20200325192509'),
('20200325192559'),
('20200325192741'),
('20200325192853'),
('20200325192927'),
('20200325193001'),
('20200325193037'),
('20200325193133'),
('20200325193215'),
('20200325193334'),
('20200325193415'),
('20200325193505'),
('20200325193619'),
('20200326193201'),
('20200328005343'),
('20200328191204'),
('20200328225422'),
('20200420222939'),
('20200420231134'),
('20200420234732'),
('20200424183225'),
('20200425201655'),
('20200425201829'),
('20200427005200'),
('20200430194458'),
('20200502021338'),
('20200601122635'),
('20200601220204'),
('20200602013522'),
('20200602062847'),
('20200603014625'),
('20200603022847'),
('20200603044417'),
('20200603220044'),
('20200610172733'),
('20200610173208'),
('20200610230840'),
('20200615072527'),
('20200701020228'),
('20200706233002'),
('20200712091052'),
('20200712091235'),
('20200722004641'),
('20200829011900'),
('20200911225159'),
('20200911231223'),
('20200912000306'),
('20200922011854'),
('20200925095907'),
('20200927001314'),
('20201001195046'),
('20201003052208'),
('20201017233817'),
('20201017235348'),
('20201017235407'),
('20201017235430'),
('20201018001652'),
('20201018002924'),
('20201019080418'),
('20210308064749'),
('20210308072329'),
('20210308200757'),
('20210320224432'),
('20210320230154'),
('20210425200153'),
('20210429194615'),
('20210501220752'),
('20210524231019');


