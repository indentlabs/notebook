SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id bigint NOT NULL,
    user_id bigint,
    key character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: api_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_requests (
    id bigint NOT NULL,
    application_integration_id bigint,
    integration_authorization_id bigint,
    result character varying,
    updates_used integer DEFAULT 0,
    ip_address character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: api_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_requests_id_seq OWNED BY public.api_requests.id;


--
-- Name: application_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_integrations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying,
    description character varying,
    organization_name character varying,
    organization_url character varying,
    website_url character varying,
    privacy_policy_url character varying,
    token character varying,
    last_used_at timestamp without time zone,
    authorization_callback_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    event_ping_url character varying,
    application_token character varying
);


--
-- Name: application_integrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_integrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_integrations_id_seq OWNED BY public.application_integrations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: archenemyships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.archenemyships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    archenemy_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: archenemyships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.archenemyships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archenemyships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.archenemyships_id_seq OWNED BY public.archenemyships.id;


--
-- Name: artifactships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artifactships (
    id integer NOT NULL,
    religion_id integer,
    artifact_id integer,
    user_id integer
);


--
-- Name: artifactships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artifactships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artifactships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artifactships_id_seq OWNED BY public.artifactships.id;


--
-- Name: attribute_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_categories (
    id integer NOT NULL,
    user_id integer,
    entity_type character varying,
    name character varying NOT NULL,
    label character varying NOT NULL,
    icon character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hidden boolean DEFAULT false,
    deleted_at timestamp without time zone,
    "position" integer
);


--
-- Name: attribute_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_categories_id_seq OWNED BY public.attribute_categories.id;


--
-- Name: attribute_category_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_category_suggestions (
    id bigint NOT NULL,
    entity_type character varying,
    suggestion character varying,
    weight integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attribute_category_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_category_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_category_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_category_suggestions_id_seq OWNED BY public.attribute_category_suggestions.id;


--
-- Name: attribute_field_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_field_suggestions (
    id bigint NOT NULL,
    entity_type character varying,
    category_label character varying,
    suggestion character varying,
    weight integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attribute_field_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_field_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_field_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_field_suggestions_id_seq OWNED BY public.attribute_field_suggestions.id;


--
-- Name: attribute_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_fields (
    id integer NOT NULL,
    user_id integer,
    attribute_category_id integer NOT NULL,
    name character varying NOT NULL,
    label character varying NOT NULL,
    field_type character varying NOT NULL,
    description text,
    privacy character varying DEFAULT 'public'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hidden boolean DEFAULT false,
    deleted_at timestamp without time zone,
    old_column_source character varying,
    "position" integer,
    field_options json,
    migrated_from_legacy boolean DEFAULT false
);


--
-- Name: attribute_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_fields_id_seq OWNED BY public.attribute_fields.id;


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attributes (
    id integer NOT NULL,
    user_id integer,
    attribute_field_id integer,
    entity_type character varying NOT NULL,
    entity_id integer NOT NULL,
    value text,
    privacy character varying DEFAULT 'private'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attributes_id_seq OWNED BY public.attributes.id;


--
-- Name: best_friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.best_friendships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    best_friend_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: best_friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.best_friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: best_friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.best_friendships_id_seq OWNED BY public.best_friendships.id;


--
-- Name: billing_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_plans (
    id integer NOT NULL,
    name character varying,
    stripe_plan_id character varying,
    monthly_cents integer,
    available boolean,
    allows_core_content boolean,
    allows_extended_content boolean,
    allows_collective_content boolean,
    allows_collaboration boolean,
    universe_limit integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    bonus_bandwidth_kb integer DEFAULT 0
);


--
-- Name: billing_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_plans_id_seq OWNED BY public.billing_plans.id;


--
-- Name: birthings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.birthings (
    id integer NOT NULL,
    character_id integer,
    birthplace_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: birthings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.birthings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: birthings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.birthings_id_seq OWNED BY public.birthings.id;


--
-- Name: building_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_countries (
    id bigint NOT NULL,
    building_id integer,
    country_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_countries_id_seq OWNED BY public.building_countries.id;


--
-- Name: building_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_landmarks (
    id bigint NOT NULL,
    building_id integer,
    landmark_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_landmarks_id_seq OWNED BY public.building_landmarks.id;


--
-- Name: building_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_locations (
    id bigint NOT NULL,
    building_id integer,
    location_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_locations_id_seq OWNED BY public.building_locations.id;


--
-- Name: building_nearby_buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_nearby_buildings (
    id bigint NOT NULL,
    building_id integer,
    nearby_building_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_nearby_buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_nearby_buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_nearby_buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_nearby_buildings_id_seq OWNED BY public.building_nearby_buildings.id;


--
-- Name: building_schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_schools (
    id bigint NOT NULL,
    building_id integer,
    district_school_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_schools_id_seq OWNED BY public.building_schools.id;


--
-- Name: building_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_towns (
    id bigint NOT NULL,
    building_id integer,
    town_id integer,
    user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_towns_id_seq OWNED BY public.building_towns.id;


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Building'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buildings_id_seq OWNED BY public.buildings.id;


--
-- Name: capital_cities_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capital_cities_relationships (
    id integer NOT NULL,
    user_id integer,
    location_id integer,
    capital_city_id integer
);


--
-- Name: capital_cities_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.capital_cities_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capital_cities_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.capital_cities_relationships_id_seq OWNED BY public.capital_cities_relationships.id;


--
-- Name: character_birthtowns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_birthtowns (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    birthtown_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_birthtowns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_birthtowns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_birthtowns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_birthtowns_id_seq OWNED BY public.character_birthtowns.id;


--
-- Name: character_companions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_companions (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    companion_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_companions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_companions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_companions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_companions_id_seq OWNED BY public.character_companions.id;


--
-- Name: character_enemies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_enemies (
    id integer NOT NULL,
    character_id integer,
    enemy_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_enemies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_enemies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_enemies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_enemies_id_seq OWNED BY public.character_enemies.id;


--
-- Name: character_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_floras (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_floras_id_seq OWNED BY public.character_floras.id;


--
-- Name: character_friends; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_friends (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    friend_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_friends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_friends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_friends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_friends_id_seq OWNED BY public.character_friends.id;


--
-- Name: character_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_items (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_items_id_seq OWNED BY public.character_items.id;


--
-- Name: character_love_interests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_love_interests (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    love_interest_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_love_interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_love_interests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_love_interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_love_interests_id_seq OWNED BY public.character_love_interests.id;


--
-- Name: character_magics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_magics (
    id integer NOT NULL,
    character_id integer,
    magic_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_magics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_magics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_magics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_magics_id_seq OWNED BY public.character_magics.id;


--
-- Name: character_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_technologies (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    technology_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: character_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_technologies_id_seq OWNED BY public.character_technologies.id;


--
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    name character varying NOT NULL,
    role character varying,
    gender character varying,
    age character varying,
    height character varying,
    weight character varying,
    haircolor character varying,
    hairstyle character varying,
    facialhair character varying,
    eyecolor character varying,
    race character varying,
    skintone character varying,
    bodytype character varying,
    identmarks character varying,
    religion text,
    politics text,
    prejudices text,
    occupation text,
    pets text,
    mannerisms text,
    birthday text,
    birthplace text,
    education text,
    background text,
    fave_color character varying,
    fave_food character varying,
    fave_possession character varying,
    fave_weapon character varying,
    fave_animal character varying,
    notes text,
    private_notes text,
    user_id integer,
    universe_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    privacy character varying,
    archetype character varying,
    aliases character varying,
    motivations character varying,
    flaws character varying,
    talents character varying,
    hobbies character varying,
    personality_type character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Character'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- Name: childrenships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.childrenships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    child_id integer
);


--
-- Name: childrenships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.childrenships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: childrenships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.childrenships_id_seq OWNED BY public.childrenships.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conditions (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Condition'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- Name: content_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_change_events (
    id integer NOT NULL,
    user_id integer,
    changed_fields text,
    content_id integer,
    content_type character varying,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_change_events_id_seq OWNED BY public.content_change_events.id;


--
-- Name: content_page_share_followings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_page_share_followings (
    id bigint NOT NULL,
    content_page_share_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_page_share_followings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_page_share_followings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_page_share_followings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_page_share_followings_id_seq OWNED BY public.content_page_share_followings.id;


--
-- Name: content_page_share_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_page_share_reports (
    id bigint NOT NULL,
    content_page_share_id bigint NOT NULL,
    user_id bigint NOT NULL,
    approved_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_page_share_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_page_share_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_page_share_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_page_share_reports_id_seq OWNED BY public.content_page_share_reports.id;


--
-- Name: content_page_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_page_shares (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    content_page_type character varying,
    content_page_id bigint,
    shared_at timestamp without time zone,
    privacy character varying,
    message character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deleted_at timestamp without time zone,
    secondary_content_page_type character varying,
    secondary_content_page_id bigint
);


--
-- Name: content_page_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_page_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_page_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_page_shares_id_seq OWNED BY public.content_page_shares.id;


--
-- Name: content_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_pages (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone
);


--
-- Name: content_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_pages_id_seq OWNED BY public.content_pages.id;


--
-- Name: continent_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_countries (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    country_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_countries_id_seq OWNED BY public.continent_countries.id;


--
-- Name: continent_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_creatures (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    creature_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_creatures_id_seq OWNED BY public.continent_creatures.id;


--
-- Name: continent_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_floras (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    flora_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_floras_id_seq OWNED BY public.continent_floras.id;


--
-- Name: continent_governments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_governments (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    government_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_governments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_governments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_governments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_governments_id_seq OWNED BY public.continent_governments.id;


--
-- Name: continent_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_landmarks (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    landmark_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


--
-- Name: continent_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_landmarks_id_seq OWNED BY public.continent_landmarks.id;


--
-- Name: continent_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_languages (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    language_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_languages_id_seq OWNED BY public.continent_languages.id;


--
-- Name: continent_popular_foods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_popular_foods (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    popular_food_id integer NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_popular_foods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_popular_foods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_popular_foods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_popular_foods_id_seq OWNED BY public.continent_popular_foods.id;


--
-- Name: continent_traditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent_traditions (
    id bigint NOT NULL,
    continent_id bigint NOT NULL,
    tradition_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: continent_traditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_traditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_traditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_traditions_id_seq OWNED BY public.continent_traditions.id;


--
-- Name: continents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continents (
    id bigint NOT NULL,
    name character varying,
    user_id bigint NOT NULL,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Continent'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: continents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continents_id_seq OWNED BY public.continents.id;


--
-- Name: contributors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contributors (
    id integer NOT NULL,
    universe_id integer,
    email character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contributors_id_seq OWNED BY public.contributors.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    universe_id integer,
    population character varying,
    currency character varying,
    laws character varying,
    sports character varying,
    area character varying,
    crops character varying,
    climate character varying,
    founding_story character varying,
    established_year character varying,
    notable_wars character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    privacy character varying,
    user_id integer,
    page_type character varying DEFAULT 'Country'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: country_bordering_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_bordering_countries (
    id bigint NOT NULL,
    country_id bigint NOT NULL,
    bordering_country_id integer NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: country_bordering_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_bordering_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_bordering_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_bordering_countries_id_seq OWNED BY public.country_bordering_countries.id;


--
-- Name: country_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_creatures (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_creatures_id_seq OWNED BY public.country_creatures.id;


--
-- Name: country_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_floras (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_floras_id_seq OWNED BY public.country_floras.id;


--
-- Name: country_governments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_governments (
    id integer NOT NULL,
    country_id integer,
    government_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_governments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_governments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_governments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_governments_id_seq OWNED BY public.country_governments.id;


--
-- Name: country_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_landmarks (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    landmark_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_landmarks_id_seq OWNED BY public.country_landmarks.id;


--
-- Name: country_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_languages (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    language_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_languages_id_seq OWNED BY public.country_languages.id;


--
-- Name: country_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_locations (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    location_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_locations_id_seq OWNED BY public.country_locations.id;


--
-- Name: country_religions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_religions (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    religion_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_religions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_religions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_religions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_religions_id_seq OWNED BY public.country_religions.id;


--
-- Name: country_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_towns (
    id integer NOT NULL,
    user_id integer,
    country_id integer,
    town_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: country_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_towns_id_seq OWNED BY public.country_towns.id;


--
-- Name: creature_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creature_relationships (
    id integer NOT NULL,
    user_id integer,
    creature_id integer,
    related_creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: creature_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creature_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creature_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creature_relationships_id_seq OWNED BY public.creature_relationships.id;


--
-- Name: creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creatures (
    id integer NOT NULL,
    name character varying,
    description character varying,
    type_of character varying,
    other_names character varying,
    universe_id integer,
    color character varying,
    shape character varying,
    size character varying,
    notable_features character varying,
    materials character varying,
    preferred_habitat character varying,
    sounds character varying,
    strengths character varying,
    weaknesses character varying,
    spoils character varying,
    aggressiveness character varying,
    attack_method character varying,
    defense_method character varying,
    maximum_speed character varying,
    food_sources character varying,
    migratory_patterns character varying,
    reproduction character varying,
    herd_patterns character varying,
    similar_animals character varying,
    symbolisms character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    notes character varying,
    private_notes character varying,
    privacy character varying,
    deleted_at timestamp without time zone,
    phylum character varying,
    class_string character varying,
    "order" character varying,
    family character varying,
    genus character varying,
    species character varying,
    page_type character varying DEFAULT 'Creature'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.creatures_id_seq OWNED BY public.creatures.id;


--
-- Name: current_ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.current_ownerships (
    id integer NOT NULL,
    user_id integer,
    item_id integer,
    current_owner_id integer
);


--
-- Name: current_ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.current_ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: current_ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.current_ownerships_id_seq OWNED BY public.current_ownerships.id;


--
-- Name: deities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deities (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    physical_description character varying,
    height character varying,
    weight character varying,
    symbols character varying,
    elements character varying,
    strengths character varying,
    weaknesses character varying,
    prayers character varying,
    rituals character varying,
    human_interaction character varying,
    notable_events character varying,
    family_history character varying,
    life_story character varying,
    notes character varying,
    private_notes character varying,
    privacy character varying,
    user_id integer,
    universe_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    page_type character varying DEFAULT 'Deity'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: deities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deities_id_seq OWNED BY public.deities.id;


--
-- Name: deity_abilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_abilities (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    ability_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_abilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_abilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_abilities_id_seq OWNED BY public.deity_abilities.id;


--
-- Name: deity_character_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_character_children (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    character_child_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_character_children_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_character_children_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_character_children_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_character_children_id_seq OWNED BY public.deity_character_children.id;


--
-- Name: deity_character_parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_character_parents (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    character_parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_character_parents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_character_parents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_character_parents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_character_parents_id_seq OWNED BY public.deity_character_parents.id;


--
-- Name: deity_character_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_character_partners (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    character_partner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_character_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_character_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_character_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_character_partners_id_seq OWNED BY public.deity_character_partners.id;


--
-- Name: deity_character_siblings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_character_siblings (
    id integer NOT NULL,
    deity_id integer,
    character_sibling_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_character_siblings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_character_siblings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_character_siblings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_character_siblings_id_seq OWNED BY public.deity_character_siblings.id;


--
-- Name: deity_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_creatures (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_creatures_id_seq OWNED BY public.deity_creatures.id;


--
-- Name: deity_deity_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_deity_children (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    deity_child_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_deity_children_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_deity_children_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_deity_children_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_deity_children_id_seq OWNED BY public.deity_deity_children.id;


--
-- Name: deity_deity_parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_deity_parents (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    deity_parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_deity_parents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_deity_parents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_deity_parents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_deity_parents_id_seq OWNED BY public.deity_deity_parents.id;


--
-- Name: deity_deity_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_deity_partners (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    deity_partner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_deity_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_deity_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_deity_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_deity_partners_id_seq OWNED BY public.deity_deity_partners.id;


--
-- Name: deity_deity_siblings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_deity_siblings (
    id integer NOT NULL,
    deity_id integer,
    deity_sibling_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_deity_siblings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_deity_siblings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_deity_siblings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_deity_siblings_id_seq OWNED BY public.deity_deity_siblings.id;


--
-- Name: deity_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_floras (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_floras_id_seq OWNED BY public.deity_floras.id;


--
-- Name: deity_races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_races (
    id integer NOT NULL,
    deity_id integer,
    race_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_races_id_seq OWNED BY public.deity_races.id;


--
-- Name: deity_related_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_related_landmarks (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    related_landmark_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_related_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_related_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_related_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_related_landmarks_id_seq OWNED BY public.deity_related_landmarks.id;


--
-- Name: deity_related_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_related_towns (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    related_town_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_related_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_related_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_related_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_related_towns_id_seq OWNED BY public.deity_related_towns.id;


--
-- Name: deity_relics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_relics (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    relic_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_relics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_relics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_relics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_relics_id_seq OWNED BY public.deity_relics.id;


--
-- Name: deity_religions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deity_religions (
    id integer NOT NULL,
    user_id integer,
    deity_id integer,
    religion_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deity_religions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deity_religions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deity_religions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deity_religions_id_seq OWNED BY public.deity_religions.id;


--
-- Name: deityships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deityships (
    id integer NOT NULL,
    religion_id integer,
    deity_id integer,
    user_id integer
);


--
-- Name: deityships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deityships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deityships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deityships_id_seq OWNED BY public.deityships.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: document_analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_analyses (
    id bigint NOT NULL,
    document_id bigint,
    word_count integer,
    page_count integer,
    paragraph_count integer,
    character_count integer,
    sentence_count integer,
    readability_score integer,
    combined_average_reading_level double precision,
    flesch_kincaid_grade_level integer,
    flesch_kincaid_age_minimum integer,
    flesch_kincaid_reading_ease double precision,
    forcast_grade_level double precision,
    coleman_liau_index double precision,
    automated_readability_index double precision,
    gunning_fog_index double precision,
    smog_grade double precision,
    adjective_count integer,
    noun_count integer,
    verb_count integer,
    pronoun_count integer,
    preposition_count integer,
    conjunction_count integer,
    adverb_count integer,
    determiner_count integer,
    n_syllable_words json,
    words_used_once_count integer,
    words_used_repeatedly_count integer,
    simple_words_count integer,
    complex_words_count integer,
    sentiment_score double precision,
    sentiment_label character varying,
    language character varying,
    sadness_score double precision,
    joy_score double precision,
    fear_score double precision,
    disgust_score double precision,
    anger_score double precision,
    words_per_sentence json,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    progress integer DEFAULT 0,
    interrogative_count integer,
    proper_noun_count integer,
    queued_at timestamp without time zone,
    linsear_write_grade double precision,
    dale_chall_grade double precision,
    unique_complex_words_count integer,
    unique_simple_words_count integer,
    hate_content_flag boolean DEFAULT false,
    hate_trigger_words character varying,
    profanity_content_flag boolean DEFAULT false,
    profanity_trigger_words character varying,
    sex_content_flag boolean DEFAULT false,
    sex_trigger_words character varying,
    violence_content_flag boolean DEFAULT false,
    violence_trigger_words character varying,
    adult_content_flag boolean DEFAULT false,
    most_used_words json,
    most_used_adjectives json,
    most_used_nouns json,
    most_used_verbs json,
    most_used_adverbs json
);


--
-- Name: document_analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_analyses_id_seq OWNED BY public.document_analyses.id;


--
-- Name: document_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_categories (
    id bigint NOT NULL,
    document_analysis_id bigint,
    label character varying,
    score double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_categories_id_seq OWNED BY public.document_categories.id;


--
-- Name: document_concepts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_concepts (
    id bigint NOT NULL,
    document_analysis_id bigint,
    text character varying,
    relevance double precision,
    reference_link character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_concepts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_concepts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_concepts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_concepts_id_seq OWNED BY public.document_concepts.id;


--
-- Name: document_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_entities (
    id bigint NOT NULL,
    entity_type character varying,
    entity_id bigint,
    text character varying,
    relevance double precision,
    document_analysis_id bigint,
    sentiment_label character varying,
    sentiment_score double precision,
    sadness_score double precision,
    joy_score double precision,
    fear_score double precision,
    disgust_score double precision,
    anger_score double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_entities_id_seq OWNED BY public.document_entities.id;


--
-- Name: document_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_revisions (
    id bigint NOT NULL,
    document_id bigint NOT NULL,
    title character varying,
    body character varying,
    synopsis character varying,
    universe_id integer,
    notes_text character varying,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: document_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_revisions_id_seq OWNED BY public.document_revisions.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    user_id integer,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying DEFAULT 'Untitled document'::character varying,
    privacy character varying DEFAULT 'private'::character varying,
    synopsis text,
    deleted_at timestamp without time zone,
    universe_id bigint,
    favorite boolean,
    notes_text text
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: end_of_day_analytics_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.end_of_day_analytics_reports (
    id bigint NOT NULL,
    day date,
    user_signups integer,
    new_monthly_subscriptions integer,
    ended_monthly_subscriptions integer,
    new_trimonthly_subscriptions integer,
    ended_trimonthly_subscriptions integer,
    new_annual_subscriptions integer,
    ended_annual_subscriptions integer,
    paid_paypal_invoices integer,
    buildings_created integer,
    characters_created integer,
    conditions_created integer,
    continents_created integer,
    countries_created integer,
    creatures_created integer,
    deities_created integer,
    floras_created integer,
    foods_created integer,
    governments_created integer,
    groups_created integer,
    items_created integer,
    jobs_created integer,
    landmarks_created integer,
    languages_created integer,
    locations_created integer,
    lores_created integer,
    magics_created integer,
    planets_created integer,
    races_created integer,
    religions_created integer,
    scenes_created integer,
    schools_created integer,
    sports_created integer,
    technologies_created integer,
    towns_created integer,
    traditions_created integer,
    universes_created integer,
    vehicles_created integer,
    documents_created integer,
    documents_edited integer,
    timelines_created integer,
    stream_shares_created integer,
    stream_comments integer,
    collections_created integer,
    collection_submissions_created integer,
    thredded_threads_created integer,
    thredded_replies_created integer,
    thredded_private_messages_created integer,
    thredded_private_replies_created integer,
    document_analyses_created integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: end_of_day_analytics_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.end_of_day_analytics_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: end_of_day_analytics_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.end_of_day_analytics_reports_id_seq OWNED BY public.end_of_day_analytics_reports.id;


--
-- Name: famous_figureships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.famous_figureships (
    id integer NOT NULL,
    user_id integer,
    race_id integer,
    famous_figure_id integer
);


--
-- Name: famous_figureships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.famous_figureships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: famous_figureships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.famous_figureships_id_seq OWNED BY public.famous_figureships.id;


--
-- Name: fatherships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fatherships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    father_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fatherships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fatherships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fatherships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fatherships_id_seq OWNED BY public.fatherships.id;


--
-- Name: flora_eaten_bies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flora_eaten_bies (
    id integer NOT NULL,
    flora_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flora_eaten_bies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flora_eaten_bies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flora_eaten_bies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flora_eaten_bies_id_seq OWNED BY public.flora_eaten_bies.id;


--
-- Name: flora_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flora_locations (
    id integer NOT NULL,
    flora_id integer,
    location_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flora_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flora_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flora_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flora_locations_id_seq OWNED BY public.flora_locations.id;


--
-- Name: flora_magical_effects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flora_magical_effects (
    id integer NOT NULL,
    flora_id integer,
    magic_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flora_magical_effects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flora_magical_effects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flora_magical_effects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flora_magical_effects_id_seq OWNED BY public.flora_magical_effects.id;


--
-- Name: flora_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flora_relationships (
    id integer NOT NULL,
    flora_id integer,
    related_flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flora_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flora_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flora_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flora_relationships_id_seq OWNED BY public.flora_relationships.id;


--
-- Name: floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.floras (
    id integer NOT NULL,
    name character varying,
    description character varying,
    aliases character varying,
    "order" character varying,
    family character varying,
    genus character varying,
    colorings character varying,
    size character varying,
    smell character varying,
    taste character varying,
    fruits character varying,
    seeds character varying,
    nuts character varying,
    berries character varying,
    medicinal_purposes character varying,
    reproduction character varying,
    seasonality character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    universe_id integer,
    notes character varying,
    private_notes character varying,
    privacy character varying,
    deleted_at timestamp without time zone,
    material_uses character varying,
    page_type character varying DEFAULT 'Flora'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.floras_id_seq OWNED BY public.floras.id;


--
-- Name: foods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.foods (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Food'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: foods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.foods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: foods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.foods_id_seq OWNED BY public.foods.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: government_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_creatures (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_creatures_id_seq OWNED BY public.government_creatures.id;


--
-- Name: government_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_groups (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_groups_id_seq OWNED BY public.government_groups.id;


--
-- Name: government_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_items (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_items_id_seq OWNED BY public.government_items.id;


--
-- Name: government_leaders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_leaders (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    leader_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_leaders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_leaders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_leaders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_leaders_id_seq OWNED BY public.government_leaders.id;


--
-- Name: government_political_figures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_political_figures (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    political_figure_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_political_figures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_political_figures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_political_figures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_political_figures_id_seq OWNED BY public.government_political_figures.id;


--
-- Name: government_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.government_technologies (
    id integer NOT NULL,
    user_id integer,
    government_id integer,
    technology_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: government_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.government_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: government_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.government_technologies_id_seq OWNED BY public.government_technologies.id;


--
-- Name: governments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.governments (
    id integer NOT NULL,
    name character varying,
    description character varying,
    type_of_government character varying,
    power_structure character varying,
    power_source character varying,
    checks_and_balances character varying,
    sociopolitical character varying,
    socioeconomical character varying,
    geocultural character varying,
    laws character varying,
    immigration character varying,
    privacy_ideologies character varying,
    electoral_process character varying,
    term_lengths character varying,
    criminal_system character varying,
    approval_ratings character varying,
    military character varying,
    navy character varying,
    airforce character varying,
    space_program character varying,
    international_relations character varying,
    civilian_life character varying,
    founding_story character varying,
    flag_design_story character varying,
    notable_wars character varying,
    notes character varying,
    private_notes character varying,
    privacy character varying,
    user_id integer,
    universe_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    page_type character varying DEFAULT 'Government'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: governments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.governments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: governments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.governments_id_seq OWNED BY public.governments.id;


--
-- Name: group_allyships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_allyships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    ally_id integer
);


--
-- Name: group_allyships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_allyships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_allyships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_allyships_id_seq OWNED BY public.group_allyships.id;


--
-- Name: group_clientships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_clientships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    client_id integer
);


--
-- Name: group_clientships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_clientships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_clientships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_clientships_id_seq OWNED BY public.group_clientships.id;


--
-- Name: group_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_creatures (
    id integer NOT NULL,
    group_id integer,
    creature_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_creatures_id_seq OWNED BY public.group_creatures.id;


--
-- Name: group_enemyships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_enemyships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    enemy_id integer
);


--
-- Name: group_enemyships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_enemyships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_enemyships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_enemyships_id_seq OWNED BY public.group_enemyships.id;


--
-- Name: group_equipmentships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_equipmentships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    equipment_id integer
);


--
-- Name: group_equipmentships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_equipmentships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_equipmentships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_equipmentships_id_seq OWNED BY public.group_equipmentships.id;


--
-- Name: group_leaderships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_leaderships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    leader_id integer
);


--
-- Name: group_leaderships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_leaderships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_leaderships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_leaderships_id_seq OWNED BY public.group_leaderships.id;


--
-- Name: group_locationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_locationships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    location_id integer
);


--
-- Name: group_locationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_locationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_locationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_locationships_id_seq OWNED BY public.group_locationships.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_memberships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    member_id integer
);


--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_memberships_id_seq OWNED BY public.group_memberships.id;


--
-- Name: group_rivalships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_rivalships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    rival_id integer
);


--
-- Name: group_rivalships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_rivalships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_rivalships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_rivalships_id_seq OWNED BY public.group_rivalships.id;


--
-- Name: group_supplierships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_supplierships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    supplier_id integer
);


--
-- Name: group_supplierships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_supplierships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_supplierships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_supplierships_id_seq OWNED BY public.group_supplierships.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    universe_id integer,
    user_id integer,
    organization_structure character varying,
    motivation character varying,
    goal character varying,
    obstacles character varying,
    risks character varying,
    inventory character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Group'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: headquarterships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.headquarterships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    headquarter_id integer
);


--
-- Name: headquarterships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.headquarterships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: headquarterships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.headquarterships_id_seq OWNED BY public.headquarterships.id;


--
-- Name: image_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_uploads (
    id integer NOT NULL,
    privacy character varying,
    user_id integer,
    content_type character varying,
    content_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    src_file_name character varying,
    src_content_type character varying,
    src_file_size bigint,
    src_updated_at timestamp without time zone
);


--
-- Name: image_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.image_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.image_uploads_id_seq OWNED BY public.image_uploads.id;


--
-- Name: integration_authorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integration_authorizations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    application_integration_id bigint NOT NULL,
    referral_url character varying,
    ip_address character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    origin character varying,
    content_type character varying,
    user_agent character varying,
    user_token character varying
);


--
-- Name: integration_authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.integration_authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: integration_authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.integration_authorizations_id_seq OWNED BY public.integration_authorizations.id;


--
-- Name: item_magics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_magics (
    id integer NOT NULL,
    item_id integer,
    magic_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: item_magics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_magics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_magics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_magics_id_seq OWNED BY public.item_magics.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name character varying NOT NULL,
    item_type character varying,
    description text,
    weight character varying,
    original_owner character varying,
    current_owner character varying,
    made_by text,
    materials text,
    year_made character varying,
    magic text,
    notes text,
    private_notes text,
    user_id integer,
    universe_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    privacy character varying DEFAULT 'private'::character varying NOT NULL,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Item'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Job'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: key_itemships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_itemships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    key_item_id integer
);


--
-- Name: key_itemships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_itemships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_itemships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_itemships_id_seq OWNED BY public.key_itemships.id;


--
-- Name: landmark_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.landmark_countries (
    id integer NOT NULL,
    user_id integer,
    landmark_id integer,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: landmark_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.landmark_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmark_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.landmark_countries_id_seq OWNED BY public.landmark_countries.id;


--
-- Name: landmark_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.landmark_creatures (
    id integer NOT NULL,
    user_id integer,
    landmark_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: landmark_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.landmark_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmark_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.landmark_creatures_id_seq OWNED BY public.landmark_creatures.id;


--
-- Name: landmark_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.landmark_floras (
    id integer NOT NULL,
    user_id integer,
    landmark_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: landmark_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.landmark_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmark_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.landmark_floras_id_seq OWNED BY public.landmark_floras.id;


--
-- Name: landmark_nearby_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.landmark_nearby_towns (
    id integer NOT NULL,
    user_id integer,
    landmark_id integer,
    nearby_town_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: landmark_nearby_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.landmark_nearby_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmark_nearby_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.landmark_nearby_towns_id_seq OWNED BY public.landmark_nearby_towns.id;


--
-- Name: landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.landmarks (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    universe_id integer,
    size character varying,
    materials character varying,
    colors character varying,
    creation_story character varying,
    established_year character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    privacy character varying,
    user_id integer,
    page_type character varying DEFAULT 'Landmark'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.landmarks_id_seq OWNED BY public.landmarks.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.languages (
    id integer NOT NULL,
    name character varying,
    other_names character varying,
    universe_id integer,
    user_id integer,
    history character varying,
    typology character varying,
    dialectical_information character varying,
    register character varying,
    phonology character varying,
    grammar character varying,
    numbers character varying,
    quantifiers character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Language'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: largest_cities_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.largest_cities_relationships (
    id integer NOT NULL,
    user_id integer,
    location_id integer,
    largest_city_id integer
);


--
-- Name: largest_cities_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.largest_cities_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: largest_cities_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.largest_cities_relationships_id_seq OWNED BY public.largest_cities_relationships.id;


--
-- Name: lingualisms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lingualisms (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    spoken_language_id integer
);


--
-- Name: lingualisms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lingualisms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lingualisms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lingualisms_id_seq OWNED BY public.lingualisms.id;


--
-- Name: location_capital_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_capital_towns (
    id integer NOT NULL,
    location_id integer,
    capital_town_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: location_capital_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_capital_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_capital_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_capital_towns_id_seq OWNED BY public.location_capital_towns.id;


--
-- Name: location_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_landmarks (
    id integer NOT NULL,
    location_id integer,
    landmark_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: location_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_landmarks_id_seq OWNED BY public.location_landmarks.id;


--
-- Name: location_languageships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_languageships (
    id integer NOT NULL,
    user_id integer,
    location_id integer,
    language_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: location_languageships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_languageships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_languageships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_languageships_id_seq OWNED BY public.location_languageships.id;


--
-- Name: location_largest_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_largest_towns (
    id integer NOT NULL,
    location_id integer,
    largest_town_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: location_largest_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_largest_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_largest_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_largest_towns_id_seq OWNED BY public.location_largest_towns.id;


--
-- Name: location_leaderships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_leaderships (
    id integer NOT NULL,
    user_id integer,
    location_id integer,
    leader_id integer
);


--
-- Name: location_leaderships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_leaderships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_leaderships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_leaderships_id_seq OWNED BY public.location_leaderships.id;


--
-- Name: location_notable_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_notable_towns (
    id integer NOT NULL,
    location_id integer,
    notable_town_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: location_notable_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_notable_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_notable_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_notable_towns_id_seq OWNED BY public.location_notable_towns.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying NOT NULL,
    type_of character varying,
    description text,
    map_file_name character varying,
    map_content_type character varying,
    map_file_size bigint,
    map_updated_at timestamp without time zone,
    population character varying,
    language character varying,
    currency character varying,
    motto character varying,
    capital text,
    largest_city text,
    notable_cities text,
    area text,
    crops text,
    located_at text,
    established_year character varying,
    notable_wars text,
    notes text,
    private_notes text,
    user_id integer,
    universe_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    privacy character varying DEFAULT 'private'::character varying NOT NULL,
    laws character varying,
    climate character varying,
    founding_story character varying,
    sports character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Location'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: lore_believers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_believers (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    believer_id integer,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_believers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_believers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_believers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_believers_id_seq OWNED BY public.lore_believers.id;


--
-- Name: lore_buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_buildings (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    building_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_buildings_id_seq OWNED BY public.lore_buildings.id;


--
-- Name: lore_characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_characters (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    character_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_characters_id_seq OWNED BY public.lore_characters.id;


--
-- Name: lore_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_conditions (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    condition_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_conditions_id_seq OWNED BY public.lore_conditions.id;


--
-- Name: lore_continents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_continents (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    continent_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_continents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_continents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_continents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_continents_id_seq OWNED BY public.lore_continents.id;


--
-- Name: lore_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_countries (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    country_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_countries_id_seq OWNED BY public.lore_countries.id;


--
-- Name: lore_created_traditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_created_traditions (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    created_tradition_id integer,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_created_traditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_created_traditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_created_traditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_created_traditions_id_seq OWNED BY public.lore_created_traditions.id;


--
-- Name: lore_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_creatures (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    creature_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_creatures_id_seq OWNED BY public.lore_creatures.id;


--
-- Name: lore_deities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_deities (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    deity_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_deities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_deities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_deities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_deities_id_seq OWNED BY public.lore_deities.id;


--
-- Name: lore_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_floras (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    flora_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_floras_id_seq OWNED BY public.lore_floras.id;


--
-- Name: lore_foods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_foods (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    food_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_foods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_foods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_foods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_foods_id_seq OWNED BY public.lore_foods.id;


--
-- Name: lore_governments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_governments (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    government_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_governments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_governments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_governments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_governments_id_seq OWNED BY public.lore_governments.id;


--
-- Name: lore_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_groups (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_groups_id_seq OWNED BY public.lore_groups.id;


--
-- Name: lore_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_jobs (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    job_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_jobs_id_seq OWNED BY public.lore_jobs.id;


--
-- Name: lore_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_landmarks (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    landmark_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_landmarks_id_seq OWNED BY public.lore_landmarks.id;


--
-- Name: lore_magics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_magics (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    magic_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_magics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_magics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_magics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_magics_id_seq OWNED BY public.lore_magics.id;


--
-- Name: lore_original_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_original_languages (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    original_language_id integer,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_original_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_original_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_original_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_original_languages_id_seq OWNED BY public.lore_original_languages.id;


--
-- Name: lore_planets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_planets (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    planet_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_planets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_planets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_planets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_planets_id_seq OWNED BY public.lore_planets.id;


--
-- Name: lore_races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_races (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    race_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_races_id_seq OWNED BY public.lore_races.id;


--
-- Name: lore_related_lores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_related_lores (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    related_lore_id integer,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_related_lores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_related_lores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_related_lores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_related_lores_id_seq OWNED BY public.lore_related_lores.id;


--
-- Name: lore_religions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_religions (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    religion_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_religions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_religions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_religions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_religions_id_seq OWNED BY public.lore_religions.id;


--
-- Name: lore_schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_schools (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    school_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_schools_id_seq OWNED BY public.lore_schools.id;


--
-- Name: lore_sports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_sports (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    sport_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_sports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_sports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_sports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_sports_id_seq OWNED BY public.lore_sports.id;


--
-- Name: lore_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_technologies (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    technology_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_technologies_id_seq OWNED BY public.lore_technologies.id;


--
-- Name: lore_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_towns (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    town_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_towns_id_seq OWNED BY public.lore_towns.id;


--
-- Name: lore_traditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_traditions (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    tradition_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_traditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_traditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_traditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_traditions_id_seq OWNED BY public.lore_traditions.id;


--
-- Name: lore_variations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_variations (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    variation_id integer,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_variations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_variations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_variations_id_seq OWNED BY public.lore_variations.id;


--
-- Name: lore_vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lore_vehicles (
    id bigint NOT NULL,
    lore_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lore_vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lore_vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lore_vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lore_vehicles_id_seq OWNED BY public.lore_vehicles.id;


--
-- Name: lores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lores (
    id bigint NOT NULL,
    name character varying,
    user_id bigint NOT NULL,
    universe_id integer,
    deleted_at timestamp without time zone,
    archived_at timestamp without time zone,
    privacy character varying,
    favorite boolean,
    page_type character varying DEFAULT 'Lore'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lores_id_seq OWNED BY public.lores.id;


--
-- Name: magic_deityships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.magic_deityships (
    id integer NOT NULL,
    user_id integer,
    magic_id integer,
    deity_id integer
);


--
-- Name: magic_deityships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.magic_deityships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: magic_deityships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.magic_deityships_id_seq OWNED BY public.magic_deityships.id;


--
-- Name: magics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.magics (
    id integer NOT NULL,
    name character varying,
    description character varying,
    type_of character varying,
    universe_id integer,
    user_id integer,
    visuals character varying,
    effects character varying,
    positive_effects character varying,
    negative_effects character varying,
    neutral_effects character varying,
    element character varying,
    resource_costs character varying,
    materials character varying,
    skills_required character varying,
    limitations character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Magic'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: magics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.magics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: magics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.magics_id_seq OWNED BY public.magics.id;


--
-- Name: maker_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_relationships (
    id integer NOT NULL,
    user_id integer,
    item_id integer,
    maker_id integer
);


--
-- Name: maker_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_relationships_id_seq OWNED BY public.maker_relationships.id;


--
-- Name: marriages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marriages (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    spouse_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: marriages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marriages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marriages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marriages_id_seq OWNED BY public.marriages.id;


--
-- Name: motherships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.motherships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    mother_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: motherships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.motherships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: motherships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.motherships_id_seq OWNED BY public.motherships.id;


--
-- Name: notable_cities_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notable_cities_relationships (
    id integer NOT NULL,
    user_id integer,
    location_id integer,
    notable_city_id integer
);


--
-- Name: notable_cities_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notable_cities_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notable_cities_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notable_cities_relationships_id_seq OWNED BY public.notable_cities_relationships.id;


--
-- Name: notice_dismissals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notice_dismissals (
    id bigint NOT NULL,
    user_id bigint,
    notice_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notice_dismissals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notice_dismissals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notice_dismissals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notice_dismissals_id_seq OWNED BY public.notice_dismissals.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id bigint,
    message_html character varying,
    icon character varying DEFAULT 'notifications_active'::character varying,
    happened_at timestamp without time zone,
    viewed_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    icon_color character varying DEFAULT 'blue'::character varying,
    passthrough_link character varying,
    reference_code character varying
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: officeships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.officeships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    office_id integer
);


--
-- Name: officeships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.officeships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: officeships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.officeships_id_seq OWNED BY public.officeships.id;


--
-- Name: original_ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.original_ownerships (
    id integer NOT NULL,
    user_id integer,
    item_id integer,
    original_owner_id integer
);


--
-- Name: original_ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.original_ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: original_ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.original_ownerships_id_seq OWNED BY public.original_ownerships.id;


--
-- Name: ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ownerships (
    id integer NOT NULL,
    character_id integer,
    item_id integer,
    user_id integer,
    favorite boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ownerships_id_seq OWNED BY public.ownerships.id;


--
-- Name: page_collection_followings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_collection_followings (
    id bigint NOT NULL,
    page_collection_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: page_collection_followings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_collection_followings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_collection_followings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_collection_followings_id_seq OWNED BY public.page_collection_followings.id;


--
-- Name: page_collection_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_collection_reports (
    id bigint NOT NULL,
    page_collection_id bigint NOT NULL,
    user_id bigint NOT NULL,
    approved_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: page_collection_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_collection_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_collection_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_collection_reports_id_seq OWNED BY public.page_collection_reports.id;


--
-- Name: page_collection_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_collection_submissions (
    id bigint NOT NULL,
    content_type character varying NOT NULL,
    content_id bigint NOT NULL,
    user_id bigint NOT NULL,
    accepted_at timestamp without time zone,
    submitted_at timestamp without time zone,
    page_collection_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    explanation character varying,
    cached_content_name character varying,
    deleted_at timestamp without time zone
);


--
-- Name: page_collection_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_collection_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_collection_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_collection_submissions_id_seq OWNED BY public.page_collection_submissions.id;


--
-- Name: page_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_collections (
    id bigint NOT NULL,
    title character varying,
    subtitle character varying,
    user_id bigint NOT NULL,
    privacy character varying,
    page_types character varying,
    color character varying,
    cover_image character varying,
    auto_accept boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    description character varying,
    allow_submissions boolean DEFAULT false,
    slug character varying,
    deleted_at timestamp without time zone
);


--
-- Name: page_collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_collections_id_seq OWNED BY public.page_collections.id;


--
-- Name: page_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_references (
    id bigint NOT NULL,
    referencing_page_type character varying NOT NULL,
    referencing_page_id bigint NOT NULL,
    referenced_page_type character varying NOT NULL,
    referenced_page_id bigint NOT NULL,
    attribute_field_id bigint,
    cached_relation_title character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    reference_type character varying
);


--
-- Name: page_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_references_id_seq OWNED BY public.page_references.id;


--
-- Name: page_settings_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_settings_overrides (
    id bigint NOT NULL,
    page_type character varying,
    name_override character varying,
    icon_override character varying,
    hex_color_override character varying,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: page_settings_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_settings_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_settings_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_settings_overrides_id_seq OWNED BY public.page_settings_overrides.id;


--
-- Name: page_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_tags (
    id bigint NOT NULL,
    page_type character varying,
    page_id bigint,
    tag character varying,
    slug character varying,
    color character varying,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: page_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_tags_id_seq OWNED BY public.page_tags.id;


--
-- Name: page_unlock_promo_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_unlock_promo_codes (
    id bigint NOT NULL,
    code character varying,
    page_types character varying,
    uses_remaining integer,
    days_active integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    internal_description character varying,
    description character varying
);


--
-- Name: page_unlock_promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_unlock_promo_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_unlock_promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_unlock_promo_codes_id_seq OWNED BY public.page_unlock_promo_codes.id;


--
-- Name: past_ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.past_ownerships (
    id integer NOT NULL,
    user_id integer,
    item_id integer,
    past_owner_id integer
);


--
-- Name: past_ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.past_ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: past_ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.past_ownerships_id_seq OWNED BY public.past_ownerships.id;


--
-- Name: paypal_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paypal_invoices (
    id bigint NOT NULL,
    paypal_id character varying,
    status character varying,
    user_id bigint NOT NULL,
    months integer,
    amount_cents integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    page_unlock_promo_code_id bigint,
    approval_url character varying,
    payer_id character varying,
    deleted_at timestamp without time zone
);


--
-- Name: paypal_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paypal_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paypal_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.paypal_invoices_id_seq OWNED BY public.paypal_invoices.id;


--
-- Name: planet_continents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_continents (
    id bigint NOT NULL,
    planet_id bigint NOT NULL,
    continent_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: planet_continents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_continents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_continents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_continents_id_seq OWNED BY public.planet_continents.id;


--
-- Name: planet_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_countries (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_countries_id_seq OWNED BY public.planet_countries.id;


--
-- Name: planet_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_creatures (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_creatures_id_seq OWNED BY public.planet_creatures.id;


--
-- Name: planet_deities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_deities (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    deity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_deities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_deities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_deities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_deities_id_seq OWNED BY public.planet_deities.id;


--
-- Name: planet_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_floras (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_floras_id_seq OWNED BY public.planet_floras.id;


--
-- Name: planet_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_groups (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_groups_id_seq OWNED BY public.planet_groups.id;


--
-- Name: planet_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_landmarks (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    landmark_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_landmarks_id_seq OWNED BY public.planet_landmarks.id;


--
-- Name: planet_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_languages (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    language_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_languages_id_seq OWNED BY public.planet_languages.id;


--
-- Name: planet_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_locations (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    location_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_locations_id_seq OWNED BY public.planet_locations.id;


--
-- Name: planet_nearby_planets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_nearby_planets (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    nearby_planet_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_nearby_planets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_nearby_planets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_nearby_planets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_nearby_planets_id_seq OWNED BY public.planet_nearby_planets.id;


--
-- Name: planet_races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_races (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    race_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_races_id_seq OWNED BY public.planet_races.id;


--
-- Name: planet_religions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_religions (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    religion_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_religions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_religions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_religions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_religions_id_seq OWNED BY public.planet_religions.id;


--
-- Name: planet_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_towns (
    id integer NOT NULL,
    user_id integer,
    planet_id integer,
    town_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planet_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planet_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planet_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planet_towns_id_seq OWNED BY public.planet_towns.id;


--
-- Name: planets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planets (
    id integer NOT NULL,
    name character varying,
    description character varying,
    size character varying,
    surface character varying,
    climate character varying,
    weather character varying,
    water_content character varying,
    natural_resources character varying,
    length_of_day character varying,
    length_of_night character varying,
    calendar_system character varying,
    population character varying,
    moons character varying,
    orbit character varying,
    visible_constellations character varying,
    first_inhabitants_story character varying,
    world_history character varying,
    private_notes character varying,
    privacy character varying,
    universe_id integer,
    user_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notes character varying,
    page_type character varying DEFAULT 'Planet'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: planets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planets_id_seq OWNED BY public.planets.id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotions (
    id bigint NOT NULL,
    user_id bigint,
    page_unlock_promo_code_id bigint,
    expires_at timestamp without time zone,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promotions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotions_id_seq OWNED BY public.promotions.id;


--
-- Name: races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.races (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    universe_id integer,
    user_id integer,
    body_shape character varying,
    skin_colors character varying,
    height character varying,
    weight character varying,
    notable_features character varying,
    variance character varying,
    clothing character varying,
    strengths character varying,
    weaknesses character varying,
    traditions character varying,
    beliefs character varying,
    governments character varying,
    technologies character varying,
    occupations character varying,
    economics character varying,
    favorite_foods character varying,
    notable_events character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Race'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.races_id_seq OWNED BY public.races.id;


--
-- Name: raceships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raceships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    race_id integer
);


--
-- Name: raceships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.raceships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: raceships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.raceships_id_seq OWNED BY public.raceships.id;


--
-- Name: raffle_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raffle_entries (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: raffle_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.raffle_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: raffle_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.raffle_entries_id_seq OWNED BY public.raffle_entries.id;


--
-- Name: referral_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.referral_codes (
    id integer NOT NULL,
    user_id integer,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: referral_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.referral_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referral_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.referral_codes_id_seq OWNED BY public.referral_codes.id;


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.referrals (
    id integer NOT NULL,
    referrer_id integer,
    referred_id integer,
    associated_code_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.referrals_id_seq OWNED BY public.referrals.id;


--
-- Name: religion_deities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.religion_deities (
    id integer NOT NULL,
    user_id integer,
    religion_id integer,
    deity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: religion_deities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.religion_deities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: religion_deities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.religion_deities_id_seq OWNED BY public.religion_deities.id;


--
-- Name: religions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.religions (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    universe_id integer,
    user_id integer,
    origin_story character varying,
    teachings character varying,
    prophecies character varying,
    places_of_worship character varying,
    worship_services character varying,
    obligations character varying,
    paradise character varying,
    initiation character varying,
    rituals character varying,
    holidays character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Religion'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: religions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.religions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: religions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.religions_id_seq OWNED BY public.religions.id;


--
-- Name: religious_figureships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.religious_figureships (
    id integer NOT NULL,
    religion_id integer,
    user_id integer,
    notable_figure_id integer
);


--
-- Name: religious_figureships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.religious_figureships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: religious_figureships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.religious_figureships_id_seq OWNED BY public.religious_figureships.id;


--
-- Name: religious_locationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.religious_locationships (
    id integer NOT NULL,
    religion_id integer,
    practicing_location_id integer,
    user_id integer
);


--
-- Name: religious_locationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.religious_locationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: religious_locationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.religious_locationships_id_seq OWNED BY public.religious_locationships.id;


--
-- Name: religious_raceships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.religious_raceships (
    id integer NOT NULL,
    religion_id integer,
    race_id integer,
    user_id integer
);


--
-- Name: religious_raceships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.religious_raceships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: religious_raceships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.religious_raceships_id_seq OWNED BY public.religious_raceships.id;


--
-- Name: scene_characterships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scene_characterships (
    id integer NOT NULL,
    user_id integer,
    scene_id integer,
    scene_character_id integer
);


--
-- Name: scene_characterships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scene_characterships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scene_characterships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scene_characterships_id_seq OWNED BY public.scene_characterships.id;


--
-- Name: scene_itemships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scene_itemships (
    id integer NOT NULL,
    user_id integer,
    scene_id integer,
    scene_item_id integer
);


--
-- Name: scene_itemships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scene_itemships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scene_itemships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scene_itemships_id_seq OWNED BY public.scene_itemships.id;


--
-- Name: scene_locationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scene_locationships (
    id integer NOT NULL,
    user_id integer,
    scene_id integer,
    scene_location_id integer
);


--
-- Name: scene_locationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scene_locationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scene_locationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scene_locationships_id_seq OWNED BY public.scene_locationships.id;


--
-- Name: scenes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenes (
    id integer NOT NULL,
    scene_number integer,
    name character varying,
    summary character varying,
    universe_id integer,
    user_id integer,
    cause character varying,
    description character varying,
    results character varying,
    prose character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    privacy character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Scene'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: scenes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scenes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scenes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scenes_id_seq OWNED BY public.scenes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'School'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: share_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.share_comments (
    id bigint NOT NULL,
    user_id bigint,
    content_page_share_id bigint NOT NULL,
    message character varying,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: share_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.share_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: share_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.share_comments_id_seq OWNED BY public.share_comments.id;


--
-- Name: siblingships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.siblingships (
    id integer NOT NULL,
    user_id integer,
    character_id integer,
    sibling_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: siblingships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.siblingships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: siblingships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.siblingships_id_seq OWNED BY public.siblingships.id;


--
-- Name: sistergroupships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sistergroupships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    sistergroup_id integer
);


--
-- Name: sistergroupships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sistergroupships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sistergroupships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sistergroupships_id_seq OWNED BY public.sistergroupships.id;


--
-- Name: sports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sports (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Sport'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: sports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sports_id_seq OWNED BY public.sports.id;


--
-- Name: stripe_event_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_event_logs (
    id integer NOT NULL,
    event_id character varying,
    event_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_event_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_event_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_event_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_event_logs_id_seq OWNED BY public.stripe_event_logs.id;


--
-- Name: subgroupships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subgroupships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    subgroup_id integer
);


--
-- Name: subgroupships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subgroupships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgroupships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subgroupships_id_seq OWNED BY public.subgroupships.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    user_id integer,
    billing_plan_id integer,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: supergroupships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supergroupships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    supergroup_id integer
);


--
-- Name: supergroupships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supergroupships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supergroupships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supergroupships_id_seq OWNED BY public.supergroupships.id;


--
-- Name: technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technologies (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    materials character varying,
    manufacturing_process character varying,
    sales_process character varying,
    cost character varying,
    rarity character varying,
    purpose character varying,
    how_it_works character varying,
    resources_used character varying,
    physical_description character varying,
    size character varying,
    weight character varying,
    colors character varying,
    notes character varying,
    private_notes character varying,
    privacy character varying,
    user_id integer,
    universe_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    page_type character varying DEFAULT 'Technology'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technologies_id_seq OWNED BY public.technologies.id;


--
-- Name: technology_characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_characters (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    character_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_characters_id_seq OWNED BY public.technology_characters.id;


--
-- Name: technology_child_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_child_technologies (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    child_technology_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_child_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_child_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_child_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_child_technologies_id_seq OWNED BY public.technology_child_technologies.id;


--
-- Name: technology_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_countries (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_countries_id_seq OWNED BY public.technology_countries.id;


--
-- Name: technology_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_creatures (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_creatures_id_seq OWNED BY public.technology_creatures.id;


--
-- Name: technology_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_groups (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_groups_id_seq OWNED BY public.technology_groups.id;


--
-- Name: technology_magics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_magics (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    magic_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_magics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_magics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_magics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_magics_id_seq OWNED BY public.technology_magics.id;


--
-- Name: technology_parent_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_parent_technologies (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    parent_technology_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_parent_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_parent_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_parent_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_parent_technologies_id_seq OWNED BY public.technology_parent_technologies.id;


--
-- Name: technology_planets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_planets (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    planet_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_planets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_planets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_planets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_planets_id_seq OWNED BY public.technology_planets.id;


--
-- Name: technology_related_technologies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_related_technologies (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    related_technology_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_related_technologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_related_technologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_related_technologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_related_technologies_id_seq OWNED BY public.technology_related_technologies.id;


--
-- Name: technology_towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technology_towns (
    id integer NOT NULL,
    user_id integer,
    technology_id integer,
    town_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: technology_towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.technology_towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technology_towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.technology_towns_id_seq OWNED BY public.technology_towns.id;


--
-- Name: thredded_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_categories (
    id bigint NOT NULL,
    messageboard_id bigint NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug text NOT NULL
);


--
-- Name: thredded_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_categories_id_seq OWNED BY public.thredded_categories.id;


--
-- Name: thredded_messageboard_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_messageboard_groups (
    id bigint NOT NULL,
    name character varying,
    "position" integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_messageboard_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_messageboard_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_messageboard_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_messageboard_groups_id_seq OWNED BY public.thredded_messageboard_groups.id;


--
-- Name: thredded_messageboard_notifications_for_followed_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_messageboard_notifications_for_followed_topics (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    messageboard_id bigint NOT NULL,
    notifier_key character varying(90) NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: thredded_messageboard_notifications_for_followed_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_messageboard_notifications_for_followed_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_messageboard_notifications_for_followed_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_messageboard_notifications_for_followed_topics_id_seq OWNED BY public.thredded_messageboard_notifications_for_followed_topics.id;


--
-- Name: thredded_messageboard_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_messageboard_users (
    id bigint NOT NULL,
    thredded_user_detail_id bigint NOT NULL,
    thredded_messageboard_id bigint NOT NULL,
    last_seen_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_messageboard_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_messageboard_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_messageboard_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_messageboard_users_id_seq OWNED BY public.thredded_messageboard_users.id;


--
-- Name: thredded_messageboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_messageboards (
    id bigint NOT NULL,
    name text NOT NULL,
    slug text,
    description text,
    topics_count integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    "position" integer NOT NULL,
    last_topic_id bigint,
    messageboard_group_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locked boolean DEFAULT false NOT NULL
);


--
-- Name: thredded_messageboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_messageboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_messageboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_messageboards_id_seq OWNED BY public.thredded_messageboards.id;


--
-- Name: thredded_notifications_for_followed_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_notifications_for_followed_topics (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    notifier_key character varying(90) NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: thredded_notifications_for_followed_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_notifications_for_followed_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_notifications_for_followed_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_notifications_for_followed_topics_id_seq OWNED BY public.thredded_notifications_for_followed_topics.id;


--
-- Name: thredded_notifications_for_private_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_notifications_for_private_topics (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    notifier_key character varying(90) NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: thredded_notifications_for_private_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_notifications_for_private_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_notifications_for_private_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_notifications_for_private_topics_id_seq OWNED BY public.thredded_notifications_for_private_topics.id;


--
-- Name: thredded_post_moderation_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_post_moderation_records (
    id bigint NOT NULL,
    post_id bigint,
    messageboard_id bigint,
    post_content text,
    post_user_id bigint,
    post_user_name text,
    moderator_id bigint,
    moderation_state integer NOT NULL,
    previous_moderation_state integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_post_moderation_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_post_moderation_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_post_moderation_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_post_moderation_records_id_seq OWNED BY public.thredded_post_moderation_records.id;


--
-- Name: thredded_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_posts (
    id bigint NOT NULL,
    user_id integer,
    content text,
    source character varying(191) DEFAULT 'web'::character varying,
    postable_id bigint NOT NULL,
    messageboard_id bigint NOT NULL,
    moderation_state integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    tsv tsvector
);


--
-- Name: thredded_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_posts_id_seq OWNED BY public.thredded_posts.id;


--
-- Name: thredded_private_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_private_posts (
    id bigint NOT NULL,
    user_id integer,
    content text,
    postable_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_private_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_private_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_private_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_private_posts_id_seq OWNED BY public.thredded_private_posts.id;


--
-- Name: thredded_private_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_private_topics (
    id bigint NOT NULL,
    user_id integer,
    last_user_id bigint,
    title text NOT NULL,
    slug text NOT NULL,
    posts_count integer DEFAULT 0,
    hash_id character varying(20) NOT NULL,
    last_post_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_private_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_private_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_private_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_private_topics_id_seq OWNED BY public.thredded_private_topics.id;


--
-- Name: thredded_private_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_private_users (
    id bigint NOT NULL,
    private_topic_id bigint,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_private_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_private_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_private_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_private_users_id_seq OWNED BY public.thredded_private_users.id;


--
-- Name: thredded_topic_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_topic_categories (
    id bigint NOT NULL,
    topic_id bigint NOT NULL,
    category_id bigint NOT NULL
);


--
-- Name: thredded_topic_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_topic_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_topic_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_topic_categories_id_seq OWNED BY public.thredded_topic_categories.id;


--
-- Name: thredded_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_topics (
    id bigint NOT NULL,
    user_id integer,
    last_user_id bigint,
    title text NOT NULL,
    slug text NOT NULL,
    messageboard_id bigint NOT NULL,
    posts_count integer DEFAULT 0 NOT NULL,
    sticky boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    hash_id character varying(20) NOT NULL,
    moderation_state integer NOT NULL,
    last_post_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: thredded_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_topics_id_seq OWNED BY public.thredded_topics.id;


--
-- Name: thredded_user_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_details (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    latest_activity_at timestamp without time zone,
    posts_count integer DEFAULT 0,
    topics_count integer DEFAULT 0,
    last_seen_at timestamp without time zone,
    moderation_state integer DEFAULT 1 NOT NULL,
    moderation_state_changed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_user_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_details_id_seq OWNED BY public.thredded_user_details.id;


--
-- Name: thredded_user_messageboard_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_messageboard_preferences (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    messageboard_id bigint NOT NULL,
    follow_topics_on_mention boolean DEFAULT true NOT NULL,
    auto_follow_topics boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_user_messageboard_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_messageboard_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_messageboard_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_messageboard_preferences_id_seq OWNED BY public.thredded_user_messageboard_preferences.id;


--
-- Name: thredded_user_post_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_post_notifications (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    post_id bigint NOT NULL,
    notified_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_user_post_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_post_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_post_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_post_notifications_id_seq OWNED BY public.thredded_user_post_notifications.id;


--
-- Name: thredded_user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_preferences (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    follow_topics_on_mention boolean DEFAULT true NOT NULL,
    auto_follow_topics boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: thredded_user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_preferences_id_seq OWNED BY public.thredded_user_preferences.id;


--
-- Name: thredded_user_private_topic_read_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_private_topic_read_states (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    postable_id bigint NOT NULL,
    read_at timestamp without time zone NOT NULL,
    unread_posts_count integer DEFAULT 0 NOT NULL,
    read_posts_count integer DEFAULT 0 NOT NULL
);


--
-- Name: thredded_user_private_topic_read_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_private_topic_read_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_private_topic_read_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_private_topic_read_states_id_seq OWNED BY public.thredded_user_private_topic_read_states.id;


--
-- Name: thredded_user_topic_follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_topic_follows (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    topic_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    reason smallint
);


--
-- Name: thredded_user_topic_follows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_topic_follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_topic_follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_topic_follows_id_seq OWNED BY public.thredded_user_topic_follows.id;


--
-- Name: thredded_user_topic_read_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thredded_user_topic_read_states (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    postable_id bigint NOT NULL,
    read_at timestamp without time zone NOT NULL,
    unread_posts_count integer DEFAULT 0 NOT NULL,
    read_posts_count integer DEFAULT 0 NOT NULL,
    messageboard_id bigint NOT NULL
);


--
-- Name: thredded_user_topic_read_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thredded_user_topic_read_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thredded_user_topic_read_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thredded_user_topic_read_states_id_seq OWNED BY public.thredded_user_topic_read_states.id;


--
-- Name: timeline_event_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_event_entities (
    id bigint NOT NULL,
    entity_type character varying NOT NULL,
    entity_id bigint NOT NULL,
    timeline_event_id bigint NOT NULL,
    notes character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: timeline_event_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timeline_event_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timeline_event_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timeline_event_entities_id_seq OWNED BY public.timeline_event_entities.id;


--
-- Name: timeline_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_events (
    id bigint NOT NULL,
    timeline_id bigint NOT NULL,
    time_label character varying,
    title character varying,
    description character varying,
    notes character varying,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: timeline_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timeline_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timeline_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timeline_events_id_seq OWNED BY public.timeline_events.id;


--
-- Name: timelines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timelines (
    id bigint NOT NULL,
    name character varying,
    universe_id bigint,
    user_id bigint NOT NULL,
    page_type character varying DEFAULT 'Timeline'::character varying,
    deleted_at timestamp without time zone,
    archived_at timestamp without time zone,
    privacy character varying DEFAULT 'private'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    description character varying,
    subtitle character varying,
    notes character varying,
    private_notes character varying,
    favorite boolean
);


--
-- Name: timelines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timelines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timelines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timelines_id_seq OWNED BY public.timelines.id;


--
-- Name: town_citizens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_citizens (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    citizen_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_citizens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_citizens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_citizens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_citizens_id_seq OWNED BY public.town_citizens.id;


--
-- Name: town_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_countries (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_countries_id_seq OWNED BY public.town_countries.id;


--
-- Name: town_creatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_creatures (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    creature_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_creatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_creatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_creatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_creatures_id_seq OWNED BY public.town_creatures.id;


--
-- Name: town_floras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_floras (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    flora_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_floras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_floras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_floras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_floras_id_seq OWNED BY public.town_floras.id;


--
-- Name: town_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_groups (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_groups_id_seq OWNED BY public.town_groups.id;


--
-- Name: town_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_languages (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    language_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_languages_id_seq OWNED BY public.town_languages.id;


--
-- Name: town_nearby_landmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.town_nearby_landmarks (
    id integer NOT NULL,
    user_id integer,
    town_id integer,
    nearby_landmark_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: town_nearby_landmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.town_nearby_landmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: town_nearby_landmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.town_nearby_landmarks_id_seq OWNED BY public.town_nearby_landmarks.id;


--
-- Name: towns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.towns (
    id integer NOT NULL,
    name character varying,
    description character varying,
    other_names character varying,
    laws character varying,
    sports character varying,
    politics character varying,
    founding_story character varying,
    established_year character varying,
    notes character varying,
    private_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    universe_id integer,
    deleted_at timestamp without time zone,
    privacy character varying,
    user_id integer,
    page_type character varying DEFAULT 'Town'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: towns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.towns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: towns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.towns_id_seq OWNED BY public.towns.id;


--
-- Name: traditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.traditions (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Tradition'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: traditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.traditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.traditions_id_seq OWNED BY public.traditions.id;


--
-- Name: universes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universes (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    history text,
    notes text,
    private_notes text,
    privacy character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    laws_of_physics character varying,
    magic_system character varying,
    technology character varying,
    genre character varying,
    deleted_at timestamp without time zone,
    page_type character varying DEFAULT 'Universe'::character varying,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: universes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.universes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.universes_id_seq OWNED BY public.universes.id;


--
-- Name: user_blockings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_blockings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    blocked_user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_blockings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_blockings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_blockings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_blockings_id_seq OWNED BY public.user_blockings.id;


--
-- Name: user_content_type_activators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_content_type_activators (
    id integer NOT NULL,
    user_id integer,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_content_type_activators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_content_type_activators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_content_type_activators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_content_type_activators_id_seq OWNED BY public.user_content_type_activators.id;


--
-- Name: user_followings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_followings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    followed_user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_followings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_followings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_followings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_followings_id_seq OWNED BY public.user_followings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying,
    email character varying NOT NULL,
    old_password character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    plan_type character varying,
    stripe_customer_id character varying,
    email_updates boolean DEFAULT true,
    selected_billing_plan_id integer,
    upload_bandwidth_kb integer DEFAULT 50000,
    secure_code character varying,
    fluid_preference boolean,
    username character varying,
    forum_administrator boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    site_administrator boolean DEFAULT false,
    forum_moderator boolean DEFAULT false,
    bio character varying,
    favorite_author character varying,
    favorite_genre character varying,
    location character varying,
    age character varying,
    gender character varying,
    interests character varying,
    forums_badge_text character varying,
    keyboard_shortcuts_preference boolean,
    favorite_book character varying,
    website character varying,
    inspirations character varying,
    other_names character varying,
    favorite_quote character varying,
    occupation character varying,
    favorite_page_type character varying,
    dark_mode_enabled boolean,
    notification_updates boolean DEFAULT true,
    community_features_enabled boolean DEFAULT true,
    private_profile boolean DEFAULT false,
    enabled_april_fools boolean
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id bigint NOT NULL,
    name character varying,
    user_id bigint,
    universe_id bigint,
    deleted_at timestamp without time zone,
    privacy character varying,
    page_type character varying DEFAULT 'Vehicle'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone,
    favorite boolean,
    columns_migrated_from_old_style boolean DEFAULT true
);


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: votables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votables (
    id integer NOT NULL,
    name character varying,
    description character varying,
    icon character varying,
    link character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votables_id_seq OWNED BY public.votables.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    user_id integer,
    votable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: wildlifeships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wildlifeships (
    id integer NOT NULL,
    user_id integer,
    creature_id integer,
    habitat_id integer
);


--
-- Name: wildlifeships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wildlifeships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wildlifeships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wildlifeships_id_seq OWNED BY public.wildlifeships.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_requests ALTER COLUMN id SET DEFAULT nextval('public.api_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_integrations ALTER COLUMN id SET DEFAULT nextval('public.application_integrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archenemyships ALTER COLUMN id SET DEFAULT nextval('public.archenemyships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifactships ALTER COLUMN id SET DEFAULT nextval('public.artifactships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_categories ALTER COLUMN id SET DEFAULT nextval('public.attribute_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_category_suggestions ALTER COLUMN id SET DEFAULT nextval('public.attribute_category_suggestions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_field_suggestions ALTER COLUMN id SET DEFAULT nextval('public.attribute_field_suggestions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_fields ALTER COLUMN id SET DEFAULT nextval('public.attribute_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes ALTER COLUMN id SET DEFAULT nextval('public.attributes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.best_friendships ALTER COLUMN id SET DEFAULT nextval('public.best_friendships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plans ALTER COLUMN id SET DEFAULT nextval('public.billing_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.birthings ALTER COLUMN id SET DEFAULT nextval('public.birthings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_countries ALTER COLUMN id SET DEFAULT nextval('public.building_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_landmarks ALTER COLUMN id SET DEFAULT nextval('public.building_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_locations ALTER COLUMN id SET DEFAULT nextval('public.building_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_nearby_buildings ALTER COLUMN id SET DEFAULT nextval('public.building_nearby_buildings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_schools ALTER COLUMN id SET DEFAULT nextval('public.building_schools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_towns ALTER COLUMN id SET DEFAULT nextval('public.building_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings ALTER COLUMN id SET DEFAULT nextval('public.buildings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capital_cities_relationships ALTER COLUMN id SET DEFAULT nextval('public.capital_cities_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_birthtowns ALTER COLUMN id SET DEFAULT nextval('public.character_birthtowns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_companions ALTER COLUMN id SET DEFAULT nextval('public.character_companions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_enemies ALTER COLUMN id SET DEFAULT nextval('public.character_enemies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_floras ALTER COLUMN id SET DEFAULT nextval('public.character_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_friends ALTER COLUMN id SET DEFAULT nextval('public.character_friends_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items ALTER COLUMN id SET DEFAULT nextval('public.character_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_love_interests ALTER COLUMN id SET DEFAULT nextval('public.character_love_interests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_magics ALTER COLUMN id SET DEFAULT nextval('public.character_magics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_technologies ALTER COLUMN id SET DEFAULT nextval('public.character_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.childrenships ALTER COLUMN id SET DEFAULT nextval('public.childrenships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_change_events ALTER COLUMN id SET DEFAULT nextval('public.content_change_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_followings ALTER COLUMN id SET DEFAULT nextval('public.content_page_share_followings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_reports ALTER COLUMN id SET DEFAULT nextval('public.content_page_share_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_shares ALTER COLUMN id SET DEFAULT nextval('public.content_page_shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_pages ALTER COLUMN id SET DEFAULT nextval('public.content_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_countries ALTER COLUMN id SET DEFAULT nextval('public.continent_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_creatures ALTER COLUMN id SET DEFAULT nextval('public.continent_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_floras ALTER COLUMN id SET DEFAULT nextval('public.continent_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_governments ALTER COLUMN id SET DEFAULT nextval('public.continent_governments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_landmarks ALTER COLUMN id SET DEFAULT nextval('public.continent_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_languages ALTER COLUMN id SET DEFAULT nextval('public.continent_languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_popular_foods ALTER COLUMN id SET DEFAULT nextval('public.continent_popular_foods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_traditions ALTER COLUMN id SET DEFAULT nextval('public.continent_traditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents ALTER COLUMN id SET DEFAULT nextval('public.continents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors ALTER COLUMN id SET DEFAULT nextval('public.contributors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_bordering_countries ALTER COLUMN id SET DEFAULT nextval('public.country_bordering_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_creatures ALTER COLUMN id SET DEFAULT nextval('public.country_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_floras ALTER COLUMN id SET DEFAULT nextval('public.country_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_governments ALTER COLUMN id SET DEFAULT nextval('public.country_governments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_landmarks ALTER COLUMN id SET DEFAULT nextval('public.country_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_languages ALTER COLUMN id SET DEFAULT nextval('public.country_languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_locations ALTER COLUMN id SET DEFAULT nextval('public.country_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_religions ALTER COLUMN id SET DEFAULT nextval('public.country_religions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_towns ALTER COLUMN id SET DEFAULT nextval('public.country_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creature_relationships ALTER COLUMN id SET DEFAULT nextval('public.creature_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creatures ALTER COLUMN id SET DEFAULT nextval('public.creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.current_ownerships ALTER COLUMN id SET DEFAULT nextval('public.current_ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deities ALTER COLUMN id SET DEFAULT nextval('public.deities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_abilities ALTER COLUMN id SET DEFAULT nextval('public.deity_abilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_children ALTER COLUMN id SET DEFAULT nextval('public.deity_character_children_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_parents ALTER COLUMN id SET DEFAULT nextval('public.deity_character_parents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_partners ALTER COLUMN id SET DEFAULT nextval('public.deity_character_partners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_siblings ALTER COLUMN id SET DEFAULT nextval('public.deity_character_siblings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_creatures ALTER COLUMN id SET DEFAULT nextval('public.deity_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_children ALTER COLUMN id SET DEFAULT nextval('public.deity_deity_children_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_parents ALTER COLUMN id SET DEFAULT nextval('public.deity_deity_parents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_partners ALTER COLUMN id SET DEFAULT nextval('public.deity_deity_partners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_siblings ALTER COLUMN id SET DEFAULT nextval('public.deity_deity_siblings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_floras ALTER COLUMN id SET DEFAULT nextval('public.deity_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_races ALTER COLUMN id SET DEFAULT nextval('public.deity_races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_landmarks ALTER COLUMN id SET DEFAULT nextval('public.deity_related_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_towns ALTER COLUMN id SET DEFAULT nextval('public.deity_related_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_relics ALTER COLUMN id SET DEFAULT nextval('public.deity_relics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_religions ALTER COLUMN id SET DEFAULT nextval('public.deity_religions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deityships ALTER COLUMN id SET DEFAULT nextval('public.deityships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_analyses ALTER COLUMN id SET DEFAULT nextval('public.document_analyses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories ALTER COLUMN id SET DEFAULT nextval('public.document_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_concepts ALTER COLUMN id SET DEFAULT nextval('public.document_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_entities ALTER COLUMN id SET DEFAULT nextval('public.document_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_revisions ALTER COLUMN id SET DEFAULT nextval('public.document_revisions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.end_of_day_analytics_reports ALTER COLUMN id SET DEFAULT nextval('public.end_of_day_analytics_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.famous_figureships ALTER COLUMN id SET DEFAULT nextval('public.famous_figureships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fatherships ALTER COLUMN id SET DEFAULT nextval('public.fatherships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_eaten_bies ALTER COLUMN id SET DEFAULT nextval('public.flora_eaten_bies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_locations ALTER COLUMN id SET DEFAULT nextval('public.flora_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_magical_effects ALTER COLUMN id SET DEFAULT nextval('public.flora_magical_effects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_relationships ALTER COLUMN id SET DEFAULT nextval('public.flora_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floras ALTER COLUMN id SET DEFAULT nextval('public.floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.foods ALTER COLUMN id SET DEFAULT nextval('public.foods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_creatures ALTER COLUMN id SET DEFAULT nextval('public.government_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_groups ALTER COLUMN id SET DEFAULT nextval('public.government_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_items ALTER COLUMN id SET DEFAULT nextval('public.government_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_leaders ALTER COLUMN id SET DEFAULT nextval('public.government_leaders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_political_figures ALTER COLUMN id SET DEFAULT nextval('public.government_political_figures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_technologies ALTER COLUMN id SET DEFAULT nextval('public.government_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governments ALTER COLUMN id SET DEFAULT nextval('public.governments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_allyships ALTER COLUMN id SET DEFAULT nextval('public.group_allyships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_clientships ALTER COLUMN id SET DEFAULT nextval('public.group_clientships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_creatures ALTER COLUMN id SET DEFAULT nextval('public.group_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_enemyships ALTER COLUMN id SET DEFAULT nextval('public.group_enemyships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_equipmentships ALTER COLUMN id SET DEFAULT nextval('public.group_equipmentships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_leaderships ALTER COLUMN id SET DEFAULT nextval('public.group_leaderships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_locationships ALTER COLUMN id SET DEFAULT nextval('public.group_locationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships ALTER COLUMN id SET DEFAULT nextval('public.group_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_rivalships ALTER COLUMN id SET DEFAULT nextval('public.group_rivalships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_supplierships ALTER COLUMN id SET DEFAULT nextval('public.group_supplierships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.headquarterships ALTER COLUMN id SET DEFAULT nextval('public.headquarterships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_uploads ALTER COLUMN id SET DEFAULT nextval('public.image_uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_authorizations ALTER COLUMN id SET DEFAULT nextval('public.integration_authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_magics ALTER COLUMN id SET DEFAULT nextval('public.item_magics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_itemships ALTER COLUMN id SET DEFAULT nextval('public.key_itemships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_countries ALTER COLUMN id SET DEFAULT nextval('public.landmark_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_creatures ALTER COLUMN id SET DEFAULT nextval('public.landmark_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_floras ALTER COLUMN id SET DEFAULT nextval('public.landmark_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_nearby_towns ALTER COLUMN id SET DEFAULT nextval('public.landmark_nearby_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmarks ALTER COLUMN id SET DEFAULT nextval('public.landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.largest_cities_relationships ALTER COLUMN id SET DEFAULT nextval('public.largest_cities_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lingualisms ALTER COLUMN id SET DEFAULT nextval('public.lingualisms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_capital_towns ALTER COLUMN id SET DEFAULT nextval('public.location_capital_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_landmarks ALTER COLUMN id SET DEFAULT nextval('public.location_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_languageships ALTER COLUMN id SET DEFAULT nextval('public.location_languageships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_largest_towns ALTER COLUMN id SET DEFAULT nextval('public.location_largest_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_leaderships ALTER COLUMN id SET DEFAULT nextval('public.location_leaderships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notable_towns ALTER COLUMN id SET DEFAULT nextval('public.location_notable_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_believers ALTER COLUMN id SET DEFAULT nextval('public.lore_believers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_buildings ALTER COLUMN id SET DEFAULT nextval('public.lore_buildings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_characters ALTER COLUMN id SET DEFAULT nextval('public.lore_characters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_conditions ALTER COLUMN id SET DEFAULT nextval('public.lore_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_continents ALTER COLUMN id SET DEFAULT nextval('public.lore_continents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_countries ALTER COLUMN id SET DEFAULT nextval('public.lore_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_created_traditions ALTER COLUMN id SET DEFAULT nextval('public.lore_created_traditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_creatures ALTER COLUMN id SET DEFAULT nextval('public.lore_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_deities ALTER COLUMN id SET DEFAULT nextval('public.lore_deities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_floras ALTER COLUMN id SET DEFAULT nextval('public.lore_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_foods ALTER COLUMN id SET DEFAULT nextval('public.lore_foods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_governments ALTER COLUMN id SET DEFAULT nextval('public.lore_governments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_groups ALTER COLUMN id SET DEFAULT nextval('public.lore_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_jobs ALTER COLUMN id SET DEFAULT nextval('public.lore_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_landmarks ALTER COLUMN id SET DEFAULT nextval('public.lore_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_magics ALTER COLUMN id SET DEFAULT nextval('public.lore_magics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_original_languages ALTER COLUMN id SET DEFAULT nextval('public.lore_original_languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_planets ALTER COLUMN id SET DEFAULT nextval('public.lore_planets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_races ALTER COLUMN id SET DEFAULT nextval('public.lore_races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_related_lores ALTER COLUMN id SET DEFAULT nextval('public.lore_related_lores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_religions ALTER COLUMN id SET DEFAULT nextval('public.lore_religions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_schools ALTER COLUMN id SET DEFAULT nextval('public.lore_schools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_sports ALTER COLUMN id SET DEFAULT nextval('public.lore_sports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_technologies ALTER COLUMN id SET DEFAULT nextval('public.lore_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_towns ALTER COLUMN id SET DEFAULT nextval('public.lore_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_traditions ALTER COLUMN id SET DEFAULT nextval('public.lore_traditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_variations ALTER COLUMN id SET DEFAULT nextval('public.lore_variations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_vehicles ALTER COLUMN id SET DEFAULT nextval('public.lore_vehicles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lores ALTER COLUMN id SET DEFAULT nextval('public.lores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magic_deityships ALTER COLUMN id SET DEFAULT nextval('public.magic_deityships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magics ALTER COLUMN id SET DEFAULT nextval('public.magics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_relationships ALTER COLUMN id SET DEFAULT nextval('public.maker_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marriages ALTER COLUMN id SET DEFAULT nextval('public.marriages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.motherships ALTER COLUMN id SET DEFAULT nextval('public.motherships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notable_cities_relationships ALTER COLUMN id SET DEFAULT nextval('public.notable_cities_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notice_dismissals ALTER COLUMN id SET DEFAULT nextval('public.notice_dismissals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officeships ALTER COLUMN id SET DEFAULT nextval('public.officeships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.original_ownerships ALTER COLUMN id SET DEFAULT nextval('public.original_ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships ALTER COLUMN id SET DEFAULT nextval('public.ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_followings ALTER COLUMN id SET DEFAULT nextval('public.page_collection_followings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_reports ALTER COLUMN id SET DEFAULT nextval('public.page_collection_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_submissions ALTER COLUMN id SET DEFAULT nextval('public.page_collection_submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collections ALTER COLUMN id SET DEFAULT nextval('public.page_collections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_references ALTER COLUMN id SET DEFAULT nextval('public.page_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_settings_overrides ALTER COLUMN id SET DEFAULT nextval('public.page_settings_overrides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_tags ALTER COLUMN id SET DEFAULT nextval('public.page_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_unlock_promo_codes ALTER COLUMN id SET DEFAULT nextval('public.page_unlock_promo_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.past_ownerships ALTER COLUMN id SET DEFAULT nextval('public.past_ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paypal_invoices ALTER COLUMN id SET DEFAULT nextval('public.paypal_invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_continents ALTER COLUMN id SET DEFAULT nextval('public.planet_continents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_countries ALTER COLUMN id SET DEFAULT nextval('public.planet_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_creatures ALTER COLUMN id SET DEFAULT nextval('public.planet_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_deities ALTER COLUMN id SET DEFAULT nextval('public.planet_deities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_floras ALTER COLUMN id SET DEFAULT nextval('public.planet_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_groups ALTER COLUMN id SET DEFAULT nextval('public.planet_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_landmarks ALTER COLUMN id SET DEFAULT nextval('public.planet_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_languages ALTER COLUMN id SET DEFAULT nextval('public.planet_languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_locations ALTER COLUMN id SET DEFAULT nextval('public.planet_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_nearby_planets ALTER COLUMN id SET DEFAULT nextval('public.planet_nearby_planets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_races ALTER COLUMN id SET DEFAULT nextval('public.planet_races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_religions ALTER COLUMN id SET DEFAULT nextval('public.planet_religions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_towns ALTER COLUMN id SET DEFAULT nextval('public.planet_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planets ALTER COLUMN id SET DEFAULT nextval('public.planets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions ALTER COLUMN id SET DEFAULT nextval('public.promotions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races ALTER COLUMN id SET DEFAULT nextval('public.races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raceships ALTER COLUMN id SET DEFAULT nextval('public.raceships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raffle_entries ALTER COLUMN id SET DEFAULT nextval('public.raffle_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referral_codes ALTER COLUMN id SET DEFAULT nextval('public.referral_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals ALTER COLUMN id SET DEFAULT nextval('public.referrals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religion_deities ALTER COLUMN id SET DEFAULT nextval('public.religion_deities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religions ALTER COLUMN id SET DEFAULT nextval('public.religions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_figureships ALTER COLUMN id SET DEFAULT nextval('public.religious_figureships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_locationships ALTER COLUMN id SET DEFAULT nextval('public.religious_locationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_raceships ALTER COLUMN id SET DEFAULT nextval('public.religious_raceships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_characterships ALTER COLUMN id SET DEFAULT nextval('public.scene_characterships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_itemships ALTER COLUMN id SET DEFAULT nextval('public.scene_itemships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_locationships ALTER COLUMN id SET DEFAULT nextval('public.scene_locationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenes ALTER COLUMN id SET DEFAULT nextval('public.scenes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_comments ALTER COLUMN id SET DEFAULT nextval('public.share_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.siblingships ALTER COLUMN id SET DEFAULT nextval('public.siblingships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sistergroupships ALTER COLUMN id SET DEFAULT nextval('public.sistergroupships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sports ALTER COLUMN id SET DEFAULT nextval('public.sports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_event_logs ALTER COLUMN id SET DEFAULT nextval('public.stripe_event_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgroupships ALTER COLUMN id SET DEFAULT nextval('public.subgroupships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supergroupships ALTER COLUMN id SET DEFAULT nextval('public.supergroupships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technologies ALTER COLUMN id SET DEFAULT nextval('public.technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_characters ALTER COLUMN id SET DEFAULT nextval('public.technology_characters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_child_technologies ALTER COLUMN id SET DEFAULT nextval('public.technology_child_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_countries ALTER COLUMN id SET DEFAULT nextval('public.technology_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_creatures ALTER COLUMN id SET DEFAULT nextval('public.technology_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_groups ALTER COLUMN id SET DEFAULT nextval('public.technology_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_magics ALTER COLUMN id SET DEFAULT nextval('public.technology_magics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_parent_technologies ALTER COLUMN id SET DEFAULT nextval('public.technology_parent_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_planets ALTER COLUMN id SET DEFAULT nextval('public.technology_planets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_related_technologies ALTER COLUMN id SET DEFAULT nextval('public.technology_related_technologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_towns ALTER COLUMN id SET DEFAULT nextval('public.technology_towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_categories ALTER COLUMN id SET DEFAULT nextval('public.thredded_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_groups ALTER COLUMN id SET DEFAULT nextval('public.thredded_messageboard_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_notifications_for_followed_topics ALTER COLUMN id SET DEFAULT nextval('public.thredded_messageboard_notifications_for_followed_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_users ALTER COLUMN id SET DEFAULT nextval('public.thredded_messageboard_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboards ALTER COLUMN id SET DEFAULT nextval('public.thredded_messageboards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_notifications_for_followed_topics ALTER COLUMN id SET DEFAULT nextval('public.thredded_notifications_for_followed_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_notifications_for_private_topics ALTER COLUMN id SET DEFAULT nextval('public.thredded_notifications_for_private_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_post_moderation_records ALTER COLUMN id SET DEFAULT nextval('public.thredded_post_moderation_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_posts ALTER COLUMN id SET DEFAULT nextval('public.thredded_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_posts ALTER COLUMN id SET DEFAULT nextval('public.thredded_private_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_topics ALTER COLUMN id SET DEFAULT nextval('public.thredded_private_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_users ALTER COLUMN id SET DEFAULT nextval('public.thredded_private_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_topic_categories ALTER COLUMN id SET DEFAULT nextval('public.thredded_topic_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_topics ALTER COLUMN id SET DEFAULT nextval('public.thredded_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_details ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_messageboard_preferences ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_messageboard_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_post_notifications ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_post_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_preferences ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_private_topic_read_states ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_private_topic_read_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_topic_follows ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_topic_follows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_topic_read_states ALTER COLUMN id SET DEFAULT nextval('public.thredded_user_topic_read_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_event_entities ALTER COLUMN id SET DEFAULT nextval('public.timeline_event_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events ALTER COLUMN id SET DEFAULT nextval('public.timeline_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timelines ALTER COLUMN id SET DEFAULT nextval('public.timelines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_citizens ALTER COLUMN id SET DEFAULT nextval('public.town_citizens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_countries ALTER COLUMN id SET DEFAULT nextval('public.town_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_creatures ALTER COLUMN id SET DEFAULT nextval('public.town_creatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_floras ALTER COLUMN id SET DEFAULT nextval('public.town_floras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_groups ALTER COLUMN id SET DEFAULT nextval('public.town_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_languages ALTER COLUMN id SET DEFAULT nextval('public.town_languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_nearby_landmarks ALTER COLUMN id SET DEFAULT nextval('public.town_nearby_landmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.towns ALTER COLUMN id SET DEFAULT nextval('public.towns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traditions ALTER COLUMN id SET DEFAULT nextval('public.traditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universes ALTER COLUMN id SET DEFAULT nextval('public.universes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blockings ALTER COLUMN id SET DEFAULT nextval('public.user_blockings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_content_type_activators ALTER COLUMN id SET DEFAULT nextval('public.user_content_type_activators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_followings ALTER COLUMN id SET DEFAULT nextval('public.user_followings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votables ALTER COLUMN id SET DEFAULT nextval('public.votables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wildlifeships ALTER COLUMN id SET DEFAULT nextval('public.wildlifeships_id_seq'::regclass);


--
-- Name: active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: api_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_requests
    ADD CONSTRAINT api_requests_pkey PRIMARY KEY (id);


--
-- Name: application_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_integrations
    ADD CONSTRAINT application_integrations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: archenemyships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archenemyships
    ADD CONSTRAINT archenemyships_pkey PRIMARY KEY (id);


--
-- Name: artifactships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifactships
    ADD CONSTRAINT artifactships_pkey PRIMARY KEY (id);


--
-- Name: attribute_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_categories
    ADD CONSTRAINT attribute_categories_pkey PRIMARY KEY (id);


--
-- Name: attribute_category_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_category_suggestions
    ADD CONSTRAINT attribute_category_suggestions_pkey PRIMARY KEY (id);


--
-- Name: attribute_field_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_field_suggestions
    ADD CONSTRAINT attribute_field_suggestions_pkey PRIMARY KEY (id);


--
-- Name: attribute_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_fields
    ADD CONSTRAINT attribute_fields_pkey PRIMARY KEY (id);


--
-- Name: attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: best_friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.best_friendships
    ADD CONSTRAINT best_friendships_pkey PRIMARY KEY (id);


--
-- Name: billing_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plans
    ADD CONSTRAINT billing_plans_pkey PRIMARY KEY (id);


--
-- Name: birthings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.birthings
    ADD CONSTRAINT birthings_pkey PRIMARY KEY (id);


--
-- Name: building_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_countries
    ADD CONSTRAINT building_countries_pkey PRIMARY KEY (id);


--
-- Name: building_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_landmarks
    ADD CONSTRAINT building_landmarks_pkey PRIMARY KEY (id);


--
-- Name: building_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_locations
    ADD CONSTRAINT building_locations_pkey PRIMARY KEY (id);


--
-- Name: building_nearby_buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_nearby_buildings
    ADD CONSTRAINT building_nearby_buildings_pkey PRIMARY KEY (id);


--
-- Name: building_schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_schools
    ADD CONSTRAINT building_schools_pkey PRIMARY KEY (id);


--
-- Name: building_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_towns
    ADD CONSTRAINT building_towns_pkey PRIMARY KEY (id);


--
-- Name: buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: capital_cities_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capital_cities_relationships
    ADD CONSTRAINT capital_cities_relationships_pkey PRIMARY KEY (id);


--
-- Name: character_birthtowns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_birthtowns
    ADD CONSTRAINT character_birthtowns_pkey PRIMARY KEY (id);


--
-- Name: character_companions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_companions
    ADD CONSTRAINT character_companions_pkey PRIMARY KEY (id);


--
-- Name: character_enemies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_enemies
    ADD CONSTRAINT character_enemies_pkey PRIMARY KEY (id);


--
-- Name: character_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_floras
    ADD CONSTRAINT character_floras_pkey PRIMARY KEY (id);


--
-- Name: character_friends_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_friends
    ADD CONSTRAINT character_friends_pkey PRIMARY KEY (id);


--
-- Name: character_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT character_items_pkey PRIMARY KEY (id);


--
-- Name: character_love_interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_love_interests
    ADD CONSTRAINT character_love_interests_pkey PRIMARY KEY (id);


--
-- Name: character_magics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_magics
    ADD CONSTRAINT character_magics_pkey PRIMARY KEY (id);


--
-- Name: character_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_technologies
    ADD CONSTRAINT character_technologies_pkey PRIMARY KEY (id);


--
-- Name: characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: childrenships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.childrenships
    ADD CONSTRAINT childrenships_pkey PRIMARY KEY (id);


--
-- Name: conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: content_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_change_events
    ADD CONSTRAINT content_change_events_pkey PRIMARY KEY (id);


--
-- Name: content_page_share_followings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_followings
    ADD CONSTRAINT content_page_share_followings_pkey PRIMARY KEY (id);


--
-- Name: content_page_share_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_reports
    ADD CONSTRAINT content_page_share_reports_pkey PRIMARY KEY (id);


--
-- Name: content_page_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_shares
    ADD CONSTRAINT content_page_shares_pkey PRIMARY KEY (id);


--
-- Name: content_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_pages
    ADD CONSTRAINT content_pages_pkey PRIMARY KEY (id);


--
-- Name: continent_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_countries
    ADD CONSTRAINT continent_countries_pkey PRIMARY KEY (id);


--
-- Name: continent_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_creatures
    ADD CONSTRAINT continent_creatures_pkey PRIMARY KEY (id);


--
-- Name: continent_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_floras
    ADD CONSTRAINT continent_floras_pkey PRIMARY KEY (id);


--
-- Name: continent_governments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_governments
    ADD CONSTRAINT continent_governments_pkey PRIMARY KEY (id);


--
-- Name: continent_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_landmarks
    ADD CONSTRAINT continent_landmarks_pkey PRIMARY KEY (id);


--
-- Name: continent_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_languages
    ADD CONSTRAINT continent_languages_pkey PRIMARY KEY (id);


--
-- Name: continent_popular_foods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_popular_foods
    ADD CONSTRAINT continent_popular_foods_pkey PRIMARY KEY (id);


--
-- Name: continent_traditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_traditions
    ADD CONSTRAINT continent_traditions_pkey PRIMARY KEY (id);


--
-- Name: continents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents
    ADD CONSTRAINT continents_pkey PRIMARY KEY (id);


--
-- Name: contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT contributors_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: country_bordering_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_bordering_countries
    ADD CONSTRAINT country_bordering_countries_pkey PRIMARY KEY (id);


--
-- Name: country_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_creatures
    ADD CONSTRAINT country_creatures_pkey PRIMARY KEY (id);


--
-- Name: country_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_floras
    ADD CONSTRAINT country_floras_pkey PRIMARY KEY (id);


--
-- Name: country_governments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_governments
    ADD CONSTRAINT country_governments_pkey PRIMARY KEY (id);


--
-- Name: country_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_landmarks
    ADD CONSTRAINT country_landmarks_pkey PRIMARY KEY (id);


--
-- Name: country_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_languages
    ADD CONSTRAINT country_languages_pkey PRIMARY KEY (id);


--
-- Name: country_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_locations
    ADD CONSTRAINT country_locations_pkey PRIMARY KEY (id);


--
-- Name: country_religions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_religions
    ADD CONSTRAINT country_religions_pkey PRIMARY KEY (id);


--
-- Name: country_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_towns
    ADD CONSTRAINT country_towns_pkey PRIMARY KEY (id);


--
-- Name: creature_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creature_relationships
    ADD CONSTRAINT creature_relationships_pkey PRIMARY KEY (id);


--
-- Name: creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creatures
    ADD CONSTRAINT creatures_pkey PRIMARY KEY (id);


--
-- Name: current_ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.current_ownerships
    ADD CONSTRAINT current_ownerships_pkey PRIMARY KEY (id);


--
-- Name: deities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deities
    ADD CONSTRAINT deities_pkey PRIMARY KEY (id);


--
-- Name: deity_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_abilities
    ADD CONSTRAINT deity_abilities_pkey PRIMARY KEY (id);


--
-- Name: deity_character_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_children
    ADD CONSTRAINT deity_character_children_pkey PRIMARY KEY (id);


--
-- Name: deity_character_parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_parents
    ADD CONSTRAINT deity_character_parents_pkey PRIMARY KEY (id);


--
-- Name: deity_character_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_partners
    ADD CONSTRAINT deity_character_partners_pkey PRIMARY KEY (id);


--
-- Name: deity_character_siblings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_siblings
    ADD CONSTRAINT deity_character_siblings_pkey PRIMARY KEY (id);


--
-- Name: deity_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_creatures
    ADD CONSTRAINT deity_creatures_pkey PRIMARY KEY (id);


--
-- Name: deity_deity_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_children
    ADD CONSTRAINT deity_deity_children_pkey PRIMARY KEY (id);


--
-- Name: deity_deity_parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_parents
    ADD CONSTRAINT deity_deity_parents_pkey PRIMARY KEY (id);


--
-- Name: deity_deity_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_partners
    ADD CONSTRAINT deity_deity_partners_pkey PRIMARY KEY (id);


--
-- Name: deity_deity_siblings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_siblings
    ADD CONSTRAINT deity_deity_siblings_pkey PRIMARY KEY (id);


--
-- Name: deity_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_floras
    ADD CONSTRAINT deity_floras_pkey PRIMARY KEY (id);


--
-- Name: deity_races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_races
    ADD CONSTRAINT deity_races_pkey PRIMARY KEY (id);


--
-- Name: deity_related_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_landmarks
    ADD CONSTRAINT deity_related_landmarks_pkey PRIMARY KEY (id);


--
-- Name: deity_related_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_towns
    ADD CONSTRAINT deity_related_towns_pkey PRIMARY KEY (id);


--
-- Name: deity_relics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_relics
    ADD CONSTRAINT deity_relics_pkey PRIMARY KEY (id);


--
-- Name: deity_religions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_religions
    ADD CONSTRAINT deity_religions_pkey PRIMARY KEY (id);


--
-- Name: deityships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deityships
    ADD CONSTRAINT deityships_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: document_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_analyses
    ADD CONSTRAINT document_analyses_pkey PRIMARY KEY (id);


--
-- Name: document_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);


--
-- Name: document_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_concepts
    ADD CONSTRAINT document_concepts_pkey PRIMARY KEY (id);


--
-- Name: document_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_entities
    ADD CONSTRAINT document_entities_pkey PRIMARY KEY (id);


--
-- Name: document_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_revisions
    ADD CONSTRAINT document_revisions_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: end_of_day_analytics_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.end_of_day_analytics_reports
    ADD CONSTRAINT end_of_day_analytics_reports_pkey PRIMARY KEY (id);


--
-- Name: famous_figureships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.famous_figureships
    ADD CONSTRAINT famous_figureships_pkey PRIMARY KEY (id);


--
-- Name: fatherships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fatherships
    ADD CONSTRAINT fatherships_pkey PRIMARY KEY (id);


--
-- Name: flora_eaten_bies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_eaten_bies
    ADD CONSTRAINT flora_eaten_bies_pkey PRIMARY KEY (id);


--
-- Name: flora_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_locations
    ADD CONSTRAINT flora_locations_pkey PRIMARY KEY (id);


--
-- Name: flora_magical_effects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_magical_effects
    ADD CONSTRAINT flora_magical_effects_pkey PRIMARY KEY (id);


--
-- Name: flora_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flora_relationships
    ADD CONSTRAINT flora_relationships_pkey PRIMARY KEY (id);


--
-- Name: floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floras
    ADD CONSTRAINT floras_pkey PRIMARY KEY (id);


--
-- Name: foods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: government_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_creatures
    ADD CONSTRAINT government_creatures_pkey PRIMARY KEY (id);


--
-- Name: government_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_groups
    ADD CONSTRAINT government_groups_pkey PRIMARY KEY (id);


--
-- Name: government_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_items
    ADD CONSTRAINT government_items_pkey PRIMARY KEY (id);


--
-- Name: government_leaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_leaders
    ADD CONSTRAINT government_leaders_pkey PRIMARY KEY (id);


--
-- Name: government_political_figures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_political_figures
    ADD CONSTRAINT government_political_figures_pkey PRIMARY KEY (id);


--
-- Name: government_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_technologies
    ADD CONSTRAINT government_technologies_pkey PRIMARY KEY (id);


--
-- Name: governments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governments
    ADD CONSTRAINT governments_pkey PRIMARY KEY (id);


--
-- Name: group_allyships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_allyships
    ADD CONSTRAINT group_allyships_pkey PRIMARY KEY (id);


--
-- Name: group_clientships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_clientships
    ADD CONSTRAINT group_clientships_pkey PRIMARY KEY (id);


--
-- Name: group_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_creatures
    ADD CONSTRAINT group_creatures_pkey PRIMARY KEY (id);


--
-- Name: group_enemyships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_enemyships
    ADD CONSTRAINT group_enemyships_pkey PRIMARY KEY (id);


--
-- Name: group_equipmentships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_equipmentships
    ADD CONSTRAINT group_equipmentships_pkey PRIMARY KEY (id);


--
-- Name: group_leaderships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_leaderships
    ADD CONSTRAINT group_leaderships_pkey PRIMARY KEY (id);


--
-- Name: group_locationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_locationships
    ADD CONSTRAINT group_locationships_pkey PRIMARY KEY (id);


--
-- Name: group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: group_rivalships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_rivalships
    ADD CONSTRAINT group_rivalships_pkey PRIMARY KEY (id);


--
-- Name: group_supplierships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_supplierships
    ADD CONSTRAINT group_supplierships_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: headquarterships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.headquarterships
    ADD CONSTRAINT headquarterships_pkey PRIMARY KEY (id);


--
-- Name: image_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_uploads
    ADD CONSTRAINT image_uploads_pkey PRIMARY KEY (id);


--
-- Name: integration_authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_authorizations
    ADD CONSTRAINT integration_authorizations_pkey PRIMARY KEY (id);


--
-- Name: item_magics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_magics
    ADD CONSTRAINT item_magics_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: key_itemships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_itemships
    ADD CONSTRAINT key_itemships_pkey PRIMARY KEY (id);


--
-- Name: landmark_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_countries
    ADD CONSTRAINT landmark_countries_pkey PRIMARY KEY (id);


--
-- Name: landmark_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_creatures
    ADD CONSTRAINT landmark_creatures_pkey PRIMARY KEY (id);


--
-- Name: landmark_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_floras
    ADD CONSTRAINT landmark_floras_pkey PRIMARY KEY (id);


--
-- Name: landmark_nearby_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_nearby_towns
    ADD CONSTRAINT landmark_nearby_towns_pkey PRIMARY KEY (id);


--
-- Name: landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmarks
    ADD CONSTRAINT landmarks_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: largest_cities_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.largest_cities_relationships
    ADD CONSTRAINT largest_cities_relationships_pkey PRIMARY KEY (id);


--
-- Name: lingualisms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lingualisms
    ADD CONSTRAINT lingualisms_pkey PRIMARY KEY (id);


--
-- Name: location_capital_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_capital_towns
    ADD CONSTRAINT location_capital_towns_pkey PRIMARY KEY (id);


--
-- Name: location_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_landmarks
    ADD CONSTRAINT location_landmarks_pkey PRIMARY KEY (id);


--
-- Name: location_languageships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_languageships
    ADD CONSTRAINT location_languageships_pkey PRIMARY KEY (id);


--
-- Name: location_largest_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_largest_towns
    ADD CONSTRAINT location_largest_towns_pkey PRIMARY KEY (id);


--
-- Name: location_leaderships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_leaderships
    ADD CONSTRAINT location_leaderships_pkey PRIMARY KEY (id);


--
-- Name: location_notable_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notable_towns
    ADD CONSTRAINT location_notable_towns_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: lore_believers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_believers
    ADD CONSTRAINT lore_believers_pkey PRIMARY KEY (id);


--
-- Name: lore_buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_buildings
    ADD CONSTRAINT lore_buildings_pkey PRIMARY KEY (id);


--
-- Name: lore_characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_characters
    ADD CONSTRAINT lore_characters_pkey PRIMARY KEY (id);


--
-- Name: lore_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_conditions
    ADD CONSTRAINT lore_conditions_pkey PRIMARY KEY (id);


--
-- Name: lore_continents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_continents
    ADD CONSTRAINT lore_continents_pkey PRIMARY KEY (id);


--
-- Name: lore_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_countries
    ADD CONSTRAINT lore_countries_pkey PRIMARY KEY (id);


--
-- Name: lore_created_traditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_created_traditions
    ADD CONSTRAINT lore_created_traditions_pkey PRIMARY KEY (id);


--
-- Name: lore_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_creatures
    ADD CONSTRAINT lore_creatures_pkey PRIMARY KEY (id);


--
-- Name: lore_deities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_deities
    ADD CONSTRAINT lore_deities_pkey PRIMARY KEY (id);


--
-- Name: lore_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_floras
    ADD CONSTRAINT lore_floras_pkey PRIMARY KEY (id);


--
-- Name: lore_foods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_foods
    ADD CONSTRAINT lore_foods_pkey PRIMARY KEY (id);


--
-- Name: lore_governments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_governments
    ADD CONSTRAINT lore_governments_pkey PRIMARY KEY (id);


--
-- Name: lore_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_groups
    ADD CONSTRAINT lore_groups_pkey PRIMARY KEY (id);


--
-- Name: lore_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_jobs
    ADD CONSTRAINT lore_jobs_pkey PRIMARY KEY (id);


--
-- Name: lore_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_landmarks
    ADD CONSTRAINT lore_landmarks_pkey PRIMARY KEY (id);


--
-- Name: lore_magics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_magics
    ADD CONSTRAINT lore_magics_pkey PRIMARY KEY (id);


--
-- Name: lore_original_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_original_languages
    ADD CONSTRAINT lore_original_languages_pkey PRIMARY KEY (id);


--
-- Name: lore_planets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_planets
    ADD CONSTRAINT lore_planets_pkey PRIMARY KEY (id);


--
-- Name: lore_races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_races
    ADD CONSTRAINT lore_races_pkey PRIMARY KEY (id);


--
-- Name: lore_related_lores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_related_lores
    ADD CONSTRAINT lore_related_lores_pkey PRIMARY KEY (id);


--
-- Name: lore_religions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_religions
    ADD CONSTRAINT lore_religions_pkey PRIMARY KEY (id);


--
-- Name: lore_schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_schools
    ADD CONSTRAINT lore_schools_pkey PRIMARY KEY (id);


--
-- Name: lore_sports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_sports
    ADD CONSTRAINT lore_sports_pkey PRIMARY KEY (id);


--
-- Name: lore_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_technologies
    ADD CONSTRAINT lore_technologies_pkey PRIMARY KEY (id);


--
-- Name: lore_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_towns
    ADD CONSTRAINT lore_towns_pkey PRIMARY KEY (id);


--
-- Name: lore_traditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_traditions
    ADD CONSTRAINT lore_traditions_pkey PRIMARY KEY (id);


--
-- Name: lore_variations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_variations
    ADD CONSTRAINT lore_variations_pkey PRIMARY KEY (id);


--
-- Name: lore_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_vehicles
    ADD CONSTRAINT lore_vehicles_pkey PRIMARY KEY (id);


--
-- Name: lores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lores
    ADD CONSTRAINT lores_pkey PRIMARY KEY (id);


--
-- Name: magic_deityships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magic_deityships
    ADD CONSTRAINT magic_deityships_pkey PRIMARY KEY (id);


--
-- Name: magics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magics
    ADD CONSTRAINT magics_pkey PRIMARY KEY (id);


--
-- Name: maker_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_relationships
    ADD CONSTRAINT maker_relationships_pkey PRIMARY KEY (id);


--
-- Name: marriages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marriages
    ADD CONSTRAINT marriages_pkey PRIMARY KEY (id);


--
-- Name: motherships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.motherships
    ADD CONSTRAINT motherships_pkey PRIMARY KEY (id);


--
-- Name: notable_cities_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notable_cities_relationships
    ADD CONSTRAINT notable_cities_relationships_pkey PRIMARY KEY (id);


--
-- Name: notice_dismissals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notice_dismissals
    ADD CONSTRAINT notice_dismissals_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: officeships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officeships
    ADD CONSTRAINT officeships_pkey PRIMARY KEY (id);


--
-- Name: original_ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.original_ownerships
    ADD CONSTRAINT original_ownerships_pkey PRIMARY KEY (id);


--
-- Name: ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (id);


--
-- Name: page_collection_followings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_followings
    ADD CONSTRAINT page_collection_followings_pkey PRIMARY KEY (id);


--
-- Name: page_collection_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_reports
    ADD CONSTRAINT page_collection_reports_pkey PRIMARY KEY (id);


--
-- Name: page_collection_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_submissions
    ADD CONSTRAINT page_collection_submissions_pkey PRIMARY KEY (id);


--
-- Name: page_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collections
    ADD CONSTRAINT page_collections_pkey PRIMARY KEY (id);


--
-- Name: page_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_references
    ADD CONSTRAINT page_references_pkey PRIMARY KEY (id);


--
-- Name: page_settings_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_settings_overrides
    ADD CONSTRAINT page_settings_overrides_pkey PRIMARY KEY (id);


--
-- Name: page_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_tags
    ADD CONSTRAINT page_tags_pkey PRIMARY KEY (id);


--
-- Name: page_unlock_promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_unlock_promo_codes
    ADD CONSTRAINT page_unlock_promo_codes_pkey PRIMARY KEY (id);


--
-- Name: past_ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.past_ownerships
    ADD CONSTRAINT past_ownerships_pkey PRIMARY KEY (id);


--
-- Name: paypal_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paypal_invoices
    ADD CONSTRAINT paypal_invoices_pkey PRIMARY KEY (id);


--
-- Name: planet_continents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_continents
    ADD CONSTRAINT planet_continents_pkey PRIMARY KEY (id);


--
-- Name: planet_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_countries
    ADD CONSTRAINT planet_countries_pkey PRIMARY KEY (id);


--
-- Name: planet_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_creatures
    ADD CONSTRAINT planet_creatures_pkey PRIMARY KEY (id);


--
-- Name: planet_deities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_deities
    ADD CONSTRAINT planet_deities_pkey PRIMARY KEY (id);


--
-- Name: planet_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_floras
    ADD CONSTRAINT planet_floras_pkey PRIMARY KEY (id);


--
-- Name: planet_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_groups
    ADD CONSTRAINT planet_groups_pkey PRIMARY KEY (id);


--
-- Name: planet_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_landmarks
    ADD CONSTRAINT planet_landmarks_pkey PRIMARY KEY (id);


--
-- Name: planet_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_languages
    ADD CONSTRAINT planet_languages_pkey PRIMARY KEY (id);


--
-- Name: planet_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_locations
    ADD CONSTRAINT planet_locations_pkey PRIMARY KEY (id);


--
-- Name: planet_nearby_planets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_nearby_planets
    ADD CONSTRAINT planet_nearby_planets_pkey PRIMARY KEY (id);


--
-- Name: planet_races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_races
    ADD CONSTRAINT planet_races_pkey PRIMARY KEY (id);


--
-- Name: planet_religions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_religions
    ADD CONSTRAINT planet_religions_pkey PRIMARY KEY (id);


--
-- Name: planet_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_towns
    ADD CONSTRAINT planet_towns_pkey PRIMARY KEY (id);


--
-- Name: planets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planets
    ADD CONSTRAINT planets_pkey PRIMARY KEY (id);


--
-- Name: promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- Name: raceships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raceships
    ADD CONSTRAINT raceships_pkey PRIMARY KEY (id);


--
-- Name: raffle_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raffle_entries
    ADD CONSTRAINT raffle_entries_pkey PRIMARY KEY (id);


--
-- Name: referral_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_pkey PRIMARY KEY (id);


--
-- Name: referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_pkey PRIMARY KEY (id);


--
-- Name: religion_deities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religion_deities
    ADD CONSTRAINT religion_deities_pkey PRIMARY KEY (id);


--
-- Name: religions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religions
    ADD CONSTRAINT religions_pkey PRIMARY KEY (id);


--
-- Name: religious_figureships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_figureships
    ADD CONSTRAINT religious_figureships_pkey PRIMARY KEY (id);


--
-- Name: religious_locationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_locationships
    ADD CONSTRAINT religious_locationships_pkey PRIMARY KEY (id);


--
-- Name: religious_raceships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religious_raceships
    ADD CONSTRAINT religious_raceships_pkey PRIMARY KEY (id);


--
-- Name: scene_characterships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_characterships
    ADD CONSTRAINT scene_characterships_pkey PRIMARY KEY (id);


--
-- Name: scene_itemships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_itemships
    ADD CONSTRAINT scene_itemships_pkey PRIMARY KEY (id);


--
-- Name: scene_locationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scene_locationships
    ADD CONSTRAINT scene_locationships_pkey PRIMARY KEY (id);


--
-- Name: scenes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenes
    ADD CONSTRAINT scenes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: share_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_comments
    ADD CONSTRAINT share_comments_pkey PRIMARY KEY (id);


--
-- Name: siblingships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.siblingships
    ADD CONSTRAINT siblingships_pkey PRIMARY KEY (id);


--
-- Name: sistergroupships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sistergroupships
    ADD CONSTRAINT sistergroupships_pkey PRIMARY KEY (id);


--
-- Name: sports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT sports_pkey PRIMARY KEY (id);


--
-- Name: stripe_event_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_event_logs
    ADD CONSTRAINT stripe_event_logs_pkey PRIMARY KEY (id);


--
-- Name: subgroupships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgroupships
    ADD CONSTRAINT subgroupships_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: supergroupships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supergroupships
    ADD CONSTRAINT supergroupships_pkey PRIMARY KEY (id);


--
-- Name: technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technologies
    ADD CONSTRAINT technologies_pkey PRIMARY KEY (id);


--
-- Name: technology_characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_characters
    ADD CONSTRAINT technology_characters_pkey PRIMARY KEY (id);


--
-- Name: technology_child_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_child_technologies
    ADD CONSTRAINT technology_child_technologies_pkey PRIMARY KEY (id);


--
-- Name: technology_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_countries
    ADD CONSTRAINT technology_countries_pkey PRIMARY KEY (id);


--
-- Name: technology_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_creatures
    ADD CONSTRAINT technology_creatures_pkey PRIMARY KEY (id);


--
-- Name: technology_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_groups
    ADD CONSTRAINT technology_groups_pkey PRIMARY KEY (id);


--
-- Name: technology_magics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_magics
    ADD CONSTRAINT technology_magics_pkey PRIMARY KEY (id);


--
-- Name: technology_parent_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_parent_technologies
    ADD CONSTRAINT technology_parent_technologies_pkey PRIMARY KEY (id);


--
-- Name: technology_planets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_planets
    ADD CONSTRAINT technology_planets_pkey PRIMARY KEY (id);


--
-- Name: technology_related_technologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_related_technologies
    ADD CONSTRAINT technology_related_technologies_pkey PRIMARY KEY (id);


--
-- Name: technology_towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_towns
    ADD CONSTRAINT technology_towns_pkey PRIMARY KEY (id);


--
-- Name: thredded_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_categories
    ADD CONSTRAINT thredded_categories_pkey PRIMARY KEY (id);


--
-- Name: thredded_messageboard_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_groups
    ADD CONSTRAINT thredded_messageboard_groups_pkey PRIMARY KEY (id);


--
-- Name: thredded_messageboard_notifications_for_followed_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_notifications_for_followed_topics
    ADD CONSTRAINT thredded_messageboard_notifications_for_followed_topics_pkey PRIMARY KEY (id);


--
-- Name: thredded_messageboard_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_users
    ADD CONSTRAINT thredded_messageboard_users_pkey PRIMARY KEY (id);


--
-- Name: thredded_messageboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboards
    ADD CONSTRAINT thredded_messageboards_pkey PRIMARY KEY (id);


--
-- Name: thredded_notifications_for_followed_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_notifications_for_followed_topics
    ADD CONSTRAINT thredded_notifications_for_followed_topics_pkey PRIMARY KEY (id);


--
-- Name: thredded_notifications_for_private_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_notifications_for_private_topics
    ADD CONSTRAINT thredded_notifications_for_private_topics_pkey PRIMARY KEY (id);


--
-- Name: thredded_post_moderation_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_post_moderation_records
    ADD CONSTRAINT thredded_post_moderation_records_pkey PRIMARY KEY (id);


--
-- Name: thredded_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_posts
    ADD CONSTRAINT thredded_posts_pkey PRIMARY KEY (id);


--
-- Name: thredded_private_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_posts
    ADD CONSTRAINT thredded_private_posts_pkey PRIMARY KEY (id);


--
-- Name: thredded_private_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_topics
    ADD CONSTRAINT thredded_private_topics_pkey PRIMARY KEY (id);


--
-- Name: thredded_private_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_private_users
    ADD CONSTRAINT thredded_private_users_pkey PRIMARY KEY (id);


--
-- Name: thredded_topic_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_topic_categories
    ADD CONSTRAINT thredded_topic_categories_pkey PRIMARY KEY (id);


--
-- Name: thredded_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_topics
    ADD CONSTRAINT thredded_topics_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_details
    ADD CONSTRAINT thredded_user_details_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_messageboard_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_messageboard_preferences
    ADD CONSTRAINT thredded_user_messageboard_preferences_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_post_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_post_notifications
    ADD CONSTRAINT thredded_user_post_notifications_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_preferences
    ADD CONSTRAINT thredded_user_preferences_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_private_topic_read_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_private_topic_read_states
    ADD CONSTRAINT thredded_user_private_topic_read_states_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_topic_follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_topic_follows
    ADD CONSTRAINT thredded_user_topic_follows_pkey PRIMARY KEY (id);


--
-- Name: thredded_user_topic_read_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_topic_read_states
    ADD CONSTRAINT thredded_user_topic_read_states_pkey PRIMARY KEY (id);


--
-- Name: timeline_event_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_event_entities
    ADD CONSTRAINT timeline_event_entities_pkey PRIMARY KEY (id);


--
-- Name: timeline_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT timeline_events_pkey PRIMARY KEY (id);


--
-- Name: timelines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timelines
    ADD CONSTRAINT timelines_pkey PRIMARY KEY (id);


--
-- Name: town_citizens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_citizens
    ADD CONSTRAINT town_citizens_pkey PRIMARY KEY (id);


--
-- Name: town_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_countries
    ADD CONSTRAINT town_countries_pkey PRIMARY KEY (id);


--
-- Name: town_creatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_creatures
    ADD CONSTRAINT town_creatures_pkey PRIMARY KEY (id);


--
-- Name: town_floras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_floras
    ADD CONSTRAINT town_floras_pkey PRIMARY KEY (id);


--
-- Name: town_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_groups
    ADD CONSTRAINT town_groups_pkey PRIMARY KEY (id);


--
-- Name: town_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_languages
    ADD CONSTRAINT town_languages_pkey PRIMARY KEY (id);


--
-- Name: town_nearby_landmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_nearby_landmarks
    ADD CONSTRAINT town_nearby_landmarks_pkey PRIMARY KEY (id);


--
-- Name: towns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.towns
    ADD CONSTRAINT towns_pkey PRIMARY KEY (id);


--
-- Name: traditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traditions
    ADD CONSTRAINT traditions_pkey PRIMARY KEY (id);


--
-- Name: universes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universes
    ADD CONSTRAINT universes_pkey PRIMARY KEY (id);


--
-- Name: user_blockings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blockings
    ADD CONSTRAINT user_blockings_pkey PRIMARY KEY (id);


--
-- Name: user_content_type_activators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_content_type_activators
    ADD CONSTRAINT user_content_type_activators_pkey PRIMARY KEY (id);


--
-- Name: user_followings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_followings
    ADD CONSTRAINT user_followings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: votables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votables
    ADD CONSTRAINT votables_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: wildlifeships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wildlifeships
    ADD CONSTRAINT wildlifeships_pkey PRIMARY KEY (id);


--
-- Name: attribute_fields_aci_label_ocs_ft; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attribute_fields_aci_label_ocs_ft ON public.attribute_fields USING btree (attribute_category_id, label, old_column_source, field_type);


--
-- Name: attribute_fields_aci_label_ocs_ui_ft; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attribute_fields_aci_label_ocs_ui_ft ON public.attribute_fields USING btree (attribute_category_id, label, old_column_source, user_id, field_type);


--
-- Name: attribute_fields_aci_ocs_ui_ft; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attribute_fields_aci_ocs_ui_ft ON public.attribute_fields USING btree (attribute_category_id, old_column_source, user_id, field_type);


--
-- Name: attribute_fields_da_ui_aci_l_h; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attribute_fields_da_ui_aci_l_h ON public.attribute_fields USING btree (deleted_at, user_id, attribute_category_id, label, hidden);


--
-- Name: attributes_afi_deleted_at_entity_id_entity_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attributes_afi_deleted_at_entity_id_entity_type ON public.attributes USING btree (attribute_field_id, deleted_at, entity_id, entity_type);


--
-- Name: attributes_afi_ui_et_ei_da; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attributes_afi_ui_et_ei_da ON public.attributes USING btree (attribute_field_id, user_id, entity_type, entity_id, deleted_at);


--
-- Name: cps_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cps_index ON public.content_page_shares USING btree (content_page_type, content_page_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: deleted_at__attribute_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deleted_at__attribute_category_id ON public.attribute_fields USING btree (deleted_at, attribute_category_id);


--
-- Name: deleted_at__attribute_field_id__entity_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deleted_at__attribute_field_id__entity_type_and_id ON public.attributes USING btree (deleted_at, attribute_field_id, entity_type, entity_id);


--
-- Name: field_lookup_by_label_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX field_lookup_by_label_index ON public.attribute_fields USING btree (user_id, attribute_category_id, label, hidden, deleted_at);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_keys_on_user_id ON public.api_keys USING btree (user_id);


--
-- Name: index_api_requests_on_application_integration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_requests_on_application_integration_id ON public.api_requests USING btree (application_integration_id);


--
-- Name: index_api_requests_on_integration_authorization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_requests_on_integration_authorization_id ON public.api_requests USING btree (integration_authorization_id);


--
-- Name: index_application_integrations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_application_integrations_on_user_id ON public.application_integrations USING btree (user_id);


--
-- Name: index_attribute_categories_on_entity_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_categories_on_entity_type ON public.attribute_categories USING btree (entity_type);


--
-- Name: index_attribute_categories_on_entity_type_and_name_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_categories_on_entity_type_and_name_and_user_id ON public.attribute_categories USING btree (entity_type, name, user_id);


--
-- Name: index_attribute_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_categories_on_name ON public.attribute_categories USING btree (name);


--
-- Name: index_attribute_categories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_categories_on_user_id ON public.attribute_categories USING btree (user_id);


--
-- Name: index_attribute_fields_on_attribute_category_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_attribute_category_id_and_deleted_at ON public.attribute_fields USING btree (attribute_category_id, deleted_at);


--
-- Name: index_attribute_fields_on_deleted_at_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_deleted_at_and_name ON public.attribute_fields USING btree (deleted_at, name);


--
-- Name: index_attribute_fields_on_deleted_at_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_deleted_at_and_position ON public.attribute_fields USING btree (deleted_at, "position");


--
-- Name: index_attribute_fields_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_user_id ON public.attribute_fields USING btree (user_id);


--
-- Name: index_attribute_fields_on_user_id_and_attribute_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_user_id_and_attribute_category_id ON public.attribute_fields USING btree (user_id, attribute_category_id);


--
-- Name: index_attribute_fields_on_user_id_and_field_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_user_id_and_field_type ON public.attribute_fields USING btree (user_id, field_type);


--
-- Name: index_attribute_fields_on_user_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_user_id_and_name ON public.attribute_fields USING btree (user_id, name);


--
-- Name: index_attribute_fields_on_user_id_and_old_column_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attribute_fields_on_user_id_and_old_column_source ON public.attribute_fields USING btree (user_id, old_column_source);


--
-- Name: index_attributes_on_attribute_field_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_attribute_field_id_and_deleted_at ON public.attributes USING btree (attribute_field_id, deleted_at);


--
-- Name: index_attributes_on_entity_type_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_entity_type_and_entity_id ON public.attributes USING btree (entity_type, entity_id);


--
-- Name: index_attributes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_user_id ON public.attributes USING btree (user_id);


--
-- Name: index_attributes_on_user_id_and_attribute_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_user_id_and_attribute_field_id ON public.attributes USING btree (user_id, attribute_field_id);


--
-- Name: index_attributes_on_user_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_user_id_and_deleted_at ON public.attributes USING btree (user_id, deleted_at);


--
-- Name: index_attributes_on_user_id_and_entity_type_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attributes_on_user_id_and_entity_type_and_entity_id ON public.attributes USING btree (user_id, entity_type, entity_id);


--
-- Name: index_buildings_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_universe_id ON public.buildings USING btree (universe_id);


--
-- Name: index_buildings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_user_id ON public.buildings USING btree (user_id);


--
-- Name: index_buildings_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_user_id_and_universe_id_and_deleted_at ON public.buildings USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_character_birthtowns_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_birthtowns_on_character_id ON public.character_birthtowns USING btree (character_id);


--
-- Name: index_character_birthtowns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_birthtowns_on_user_id ON public.character_birthtowns USING btree (user_id);


--
-- Name: index_character_companions_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_companions_on_character_id ON public.character_companions USING btree (character_id);


--
-- Name: index_character_companions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_companions_on_user_id ON public.character_companions USING btree (user_id);


--
-- Name: index_character_enemies_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_enemies_on_character_id ON public.character_enemies USING btree (character_id);


--
-- Name: index_character_enemies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_enemies_on_user_id ON public.character_enemies USING btree (user_id);


--
-- Name: index_character_floras_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_floras_on_character_id ON public.character_floras USING btree (character_id);


--
-- Name: index_character_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_floras_on_flora_id ON public.character_floras USING btree (flora_id);


--
-- Name: index_character_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_floras_on_user_id ON public.character_floras USING btree (user_id);


--
-- Name: index_character_friends_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_friends_on_character_id ON public.character_friends USING btree (character_id);


--
-- Name: index_character_friends_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_friends_on_user_id ON public.character_friends USING btree (user_id);


--
-- Name: index_character_items_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_items_on_character_id ON public.character_items USING btree (character_id);


--
-- Name: index_character_items_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_items_on_item_id ON public.character_items USING btree (item_id);


--
-- Name: index_character_items_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_items_on_user_id ON public.character_items USING btree (user_id);


--
-- Name: index_character_love_interests_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_love_interests_on_character_id ON public.character_love_interests USING btree (character_id);


--
-- Name: index_character_love_interests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_love_interests_on_user_id ON public.character_love_interests USING btree (user_id);


--
-- Name: index_character_magics_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_magics_on_character_id ON public.character_magics USING btree (character_id);


--
-- Name: index_character_magics_on_magic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_magics_on_magic_id ON public.character_magics USING btree (magic_id);


--
-- Name: index_character_magics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_magics_on_user_id ON public.character_magics USING btree (user_id);


--
-- Name: index_character_technologies_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_technologies_on_character_id ON public.character_technologies USING btree (character_id);


--
-- Name: index_character_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_technologies_on_technology_id ON public.character_technologies USING btree (technology_id);


--
-- Name: index_character_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_technologies_on_user_id ON public.character_technologies USING btree (user_id);


--
-- Name: index_characters_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_deleted_at ON public.characters USING btree (deleted_at);


--
-- Name: index_characters_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_deleted_at_and_id ON public.characters USING btree (deleted_at, id);


--
-- Name: index_characters_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_deleted_at_and_universe_id ON public.characters USING btree (deleted_at, universe_id);


--
-- Name: index_characters_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_deleted_at_and_user_id ON public.characters USING btree (deleted_at, user_id);


--
-- Name: index_characters_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_id_and_deleted_at ON public.characters USING btree (id, deleted_at);


--
-- Name: index_characters_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_universe_id ON public.characters USING btree (universe_id);


--
-- Name: index_characters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_user_id ON public.characters USING btree (user_id);


--
-- Name: index_characters_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_user_id_and_universe_id_and_deleted_at ON public.characters USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_conditions_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_universe_id ON public.conditions USING btree (universe_id);


--
-- Name: index_conditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_user_id ON public.conditions USING btree (user_id);


--
-- Name: index_conditions_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_user_id_and_universe_id_and_deleted_at ON public.conditions USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_content_change_events_on_content_id_and_content_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_change_events_on_content_id_and_content_type ON public.content_change_events USING btree (content_id, content_type);


--
-- Name: index_content_change_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_change_events_on_user_id ON public.content_change_events USING btree (user_id);


--
-- Name: index_content_page_share_followings_on_content_page_share_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_page_share_followings_on_content_page_share_id ON public.content_page_share_followings USING btree (content_page_share_id);


--
-- Name: index_content_page_share_followings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_page_share_followings_on_user_id ON public.content_page_share_followings USING btree (user_id);


--
-- Name: index_content_page_share_reports_on_content_page_share_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_page_share_reports_on_content_page_share_id ON public.content_page_share_reports USING btree (content_page_share_id);


--
-- Name: index_content_page_share_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_page_share_reports_on_user_id ON public.content_page_share_reports USING btree (user_id);


--
-- Name: index_content_page_shares_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_page_shares_on_user_id ON public.content_page_shares USING btree (user_id);


--
-- Name: index_content_pages_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_pages_on_universe_id ON public.content_pages USING btree (universe_id);


--
-- Name: index_content_pages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_pages_on_user_id ON public.content_pages USING btree (user_id);


--
-- Name: index_continent_countries_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_countries_on_continent_id ON public.continent_countries USING btree (continent_id);


--
-- Name: index_continent_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_countries_on_country_id ON public.continent_countries USING btree (country_id);


--
-- Name: index_continent_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_countries_on_user_id ON public.continent_countries USING btree (user_id);


--
-- Name: index_continent_creatures_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_creatures_on_continent_id ON public.continent_creatures USING btree (continent_id);


--
-- Name: index_continent_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_creatures_on_creature_id ON public.continent_creatures USING btree (creature_id);


--
-- Name: index_continent_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_creatures_on_user_id ON public.continent_creatures USING btree (user_id);


--
-- Name: index_continent_floras_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_floras_on_continent_id ON public.continent_floras USING btree (continent_id);


--
-- Name: index_continent_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_floras_on_flora_id ON public.continent_floras USING btree (flora_id);


--
-- Name: index_continent_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_floras_on_user_id ON public.continent_floras USING btree (user_id);


--
-- Name: index_continent_governments_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_governments_on_continent_id ON public.continent_governments USING btree (continent_id);


--
-- Name: index_continent_governments_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_governments_on_government_id ON public.continent_governments USING btree (government_id);


--
-- Name: index_continent_governments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_governments_on_user_id ON public.continent_governments USING btree (user_id);


--
-- Name: index_continent_landmarks_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_landmarks_on_continent_id ON public.continent_landmarks USING btree (continent_id);


--
-- Name: index_continent_landmarks_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_landmarks_on_landmark_id ON public.continent_landmarks USING btree (landmark_id);


--
-- Name: index_continent_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_landmarks_on_user_id ON public.continent_landmarks USING btree (user_id);


--
-- Name: index_continent_languages_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_languages_on_continent_id ON public.continent_languages USING btree (continent_id);


--
-- Name: index_continent_languages_on_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_languages_on_language_id ON public.continent_languages USING btree (language_id);


--
-- Name: index_continent_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_languages_on_user_id ON public.continent_languages USING btree (user_id);


--
-- Name: index_continent_popular_foods_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_popular_foods_on_continent_id ON public.continent_popular_foods USING btree (continent_id);


--
-- Name: index_continent_popular_foods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_popular_foods_on_user_id ON public.continent_popular_foods USING btree (user_id);


--
-- Name: index_continent_traditions_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_traditions_on_continent_id ON public.continent_traditions USING btree (continent_id);


--
-- Name: index_continent_traditions_on_tradition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_traditions_on_tradition_id ON public.continent_traditions USING btree (tradition_id);


--
-- Name: index_continent_traditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continent_traditions_on_user_id ON public.continent_traditions USING btree (user_id);


--
-- Name: index_continents_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_deleted_at_and_id ON public.continents USING btree (deleted_at, id);


--
-- Name: index_continents_on_deleted_at_and_id_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_deleted_at_and_id_and_universe_id ON public.continents USING btree (deleted_at, id, universe_id);


--
-- Name: index_continents_on_deleted_at_and_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_deleted_at_and_id_and_user_id ON public.continents USING btree (deleted_at, id, user_id);


--
-- Name: index_continents_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_deleted_at_and_user_id ON public.continents USING btree (deleted_at, user_id);


--
-- Name: index_continents_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_universe_id ON public.continents USING btree (universe_id);


--
-- Name: index_continents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_continents_on_user_id ON public.continents USING btree (user_id);


--
-- Name: index_contributors_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_universe_id ON public.contributors USING btree (universe_id);


--
-- Name: index_contributors_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_user_id ON public.contributors USING btree (user_id);


--
-- Name: index_countries_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_deleted_at_and_id ON public.countries USING btree (deleted_at, id);


--
-- Name: index_countries_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_deleted_at_and_universe_id ON public.countries USING btree (deleted_at, universe_id);


--
-- Name: index_countries_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_deleted_at_and_user_id ON public.countries USING btree (deleted_at, user_id);


--
-- Name: index_countries_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_id_and_deleted_at ON public.countries USING btree (id, deleted_at);


--
-- Name: index_countries_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_universe_id ON public.countries USING btree (universe_id);


--
-- Name: index_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_user_id ON public.countries USING btree (user_id);


--
-- Name: index_countries_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_user_id_and_universe_id_and_deleted_at ON public.countries USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_country_bordering_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_bordering_countries_on_country_id ON public.country_bordering_countries USING btree (country_id);


--
-- Name: index_country_bordering_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_bordering_countries_on_user_id ON public.country_bordering_countries USING btree (user_id);


--
-- Name: index_country_creatures_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_creatures_on_country_id ON public.country_creatures USING btree (country_id);


--
-- Name: index_country_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_creatures_on_creature_id ON public.country_creatures USING btree (creature_id);


--
-- Name: index_country_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_creatures_on_user_id ON public.country_creatures USING btree (user_id);


--
-- Name: index_country_floras_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_floras_on_country_id ON public.country_floras USING btree (country_id);


--
-- Name: index_country_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_floras_on_flora_id ON public.country_floras USING btree (flora_id);


--
-- Name: index_country_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_floras_on_user_id ON public.country_floras USING btree (user_id);


--
-- Name: index_country_governments_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_governments_on_country_id ON public.country_governments USING btree (country_id);


--
-- Name: index_country_governments_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_governments_on_government_id ON public.country_governments USING btree (government_id);


--
-- Name: index_country_governments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_governments_on_user_id ON public.country_governments USING btree (user_id);


--
-- Name: index_country_landmarks_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_landmarks_on_country_id ON public.country_landmarks USING btree (country_id);


--
-- Name: index_country_landmarks_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_landmarks_on_landmark_id ON public.country_landmarks USING btree (landmark_id);


--
-- Name: index_country_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_landmarks_on_user_id ON public.country_landmarks USING btree (user_id);


--
-- Name: index_country_languages_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_languages_on_country_id ON public.country_languages USING btree (country_id);


--
-- Name: index_country_languages_on_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_languages_on_language_id ON public.country_languages USING btree (language_id);


--
-- Name: index_country_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_languages_on_user_id ON public.country_languages USING btree (user_id);


--
-- Name: index_country_locations_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_locations_on_country_id ON public.country_locations USING btree (country_id);


--
-- Name: index_country_locations_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_locations_on_location_id ON public.country_locations USING btree (location_id);


--
-- Name: index_country_locations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_locations_on_user_id ON public.country_locations USING btree (user_id);


--
-- Name: index_country_religions_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_religions_on_country_id ON public.country_religions USING btree (country_id);


--
-- Name: index_country_religions_on_religion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_religions_on_religion_id ON public.country_religions USING btree (religion_id);


--
-- Name: index_country_religions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_religions_on_user_id ON public.country_religions USING btree (user_id);


--
-- Name: index_country_towns_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_towns_on_country_id ON public.country_towns USING btree (country_id);


--
-- Name: index_country_towns_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_towns_on_town_id ON public.country_towns USING btree (town_id);


--
-- Name: index_country_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_towns_on_user_id ON public.country_towns USING btree (user_id);


--
-- Name: index_creatures_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_deleted_at ON public.creatures USING btree (deleted_at);


--
-- Name: index_creatures_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_deleted_at_and_id ON public.creatures USING btree (deleted_at, id);


--
-- Name: index_creatures_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_deleted_at_and_universe_id ON public.creatures USING btree (deleted_at, universe_id);


--
-- Name: index_creatures_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_deleted_at_and_user_id ON public.creatures USING btree (deleted_at, user_id);


--
-- Name: index_creatures_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_id_and_deleted_at ON public.creatures USING btree (id, deleted_at);


--
-- Name: index_creatures_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_universe_id ON public.creatures USING btree (universe_id);


--
-- Name: index_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_user_id ON public.creatures USING btree (user_id);


--
-- Name: index_creatures_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creatures_on_user_id_and_universe_id_and_deleted_at ON public.creatures USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_deities_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_deleted_at_and_id ON public.deities USING btree (deleted_at, id);


--
-- Name: index_deities_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_deleted_at_and_universe_id ON public.deities USING btree (deleted_at, universe_id);


--
-- Name: index_deities_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_deleted_at_and_user_id ON public.deities USING btree (deleted_at, user_id);


--
-- Name: index_deities_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_id_and_deleted_at ON public.deities USING btree (id, deleted_at);


--
-- Name: index_deities_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_universe_id ON public.deities USING btree (universe_id);


--
-- Name: index_deities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_user_id ON public.deities USING btree (user_id);


--
-- Name: index_deities_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deities_on_user_id_and_universe_id_and_deleted_at ON public.deities USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_deity_abilities_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_abilities_on_deity_id ON public.deity_abilities USING btree (deity_id);


--
-- Name: index_deity_abilities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_abilities_on_user_id ON public.deity_abilities USING btree (user_id);


--
-- Name: index_deity_character_children_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_children_on_deity_id ON public.deity_character_children USING btree (deity_id);


--
-- Name: index_deity_character_children_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_children_on_user_id ON public.deity_character_children USING btree (user_id);


--
-- Name: index_deity_character_parents_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_parents_on_deity_id ON public.deity_character_parents USING btree (deity_id);


--
-- Name: index_deity_character_parents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_parents_on_user_id ON public.deity_character_parents USING btree (user_id);


--
-- Name: index_deity_character_partners_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_partners_on_deity_id ON public.deity_character_partners USING btree (deity_id);


--
-- Name: index_deity_character_partners_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_partners_on_user_id ON public.deity_character_partners USING btree (user_id);


--
-- Name: index_deity_character_siblings_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_siblings_on_deity_id ON public.deity_character_siblings USING btree (deity_id);


--
-- Name: index_deity_character_siblings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_character_siblings_on_user_id ON public.deity_character_siblings USING btree (user_id);


--
-- Name: index_deity_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_creatures_on_creature_id ON public.deity_creatures USING btree (creature_id);


--
-- Name: index_deity_creatures_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_creatures_on_deity_id ON public.deity_creatures USING btree (deity_id);


--
-- Name: index_deity_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_creatures_on_user_id ON public.deity_creatures USING btree (user_id);


--
-- Name: index_deity_deity_children_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_children_on_deity_id ON public.deity_deity_children USING btree (deity_id);


--
-- Name: index_deity_deity_children_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_children_on_user_id ON public.deity_deity_children USING btree (user_id);


--
-- Name: index_deity_deity_parents_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_parents_on_deity_id ON public.deity_deity_parents USING btree (deity_id);


--
-- Name: index_deity_deity_parents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_parents_on_user_id ON public.deity_deity_parents USING btree (user_id);


--
-- Name: index_deity_deity_partners_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_partners_on_deity_id ON public.deity_deity_partners USING btree (deity_id);


--
-- Name: index_deity_deity_partners_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_partners_on_user_id ON public.deity_deity_partners USING btree (user_id);


--
-- Name: index_deity_deity_siblings_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_siblings_on_deity_id ON public.deity_deity_siblings USING btree (deity_id);


--
-- Name: index_deity_deity_siblings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_deity_siblings_on_user_id ON public.deity_deity_siblings USING btree (user_id);


--
-- Name: index_deity_floras_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_floras_on_deity_id ON public.deity_floras USING btree (deity_id);


--
-- Name: index_deity_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_floras_on_flora_id ON public.deity_floras USING btree (flora_id);


--
-- Name: index_deity_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_floras_on_user_id ON public.deity_floras USING btree (user_id);


--
-- Name: index_deity_races_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_races_on_deity_id ON public.deity_races USING btree (deity_id);


--
-- Name: index_deity_races_on_race_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_races_on_race_id ON public.deity_races USING btree (race_id);


--
-- Name: index_deity_races_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_races_on_user_id ON public.deity_races USING btree (user_id);


--
-- Name: index_deity_related_landmarks_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_related_landmarks_on_deity_id ON public.deity_related_landmarks USING btree (deity_id);


--
-- Name: index_deity_related_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_related_landmarks_on_user_id ON public.deity_related_landmarks USING btree (user_id);


--
-- Name: index_deity_related_towns_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_related_towns_on_deity_id ON public.deity_related_towns USING btree (deity_id);


--
-- Name: index_deity_related_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_related_towns_on_user_id ON public.deity_related_towns USING btree (user_id);


--
-- Name: index_deity_relics_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_relics_on_deity_id ON public.deity_relics USING btree (deity_id);


--
-- Name: index_deity_relics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_relics_on_user_id ON public.deity_relics USING btree (user_id);


--
-- Name: index_deity_religions_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_religions_on_deity_id ON public.deity_religions USING btree (deity_id);


--
-- Name: index_deity_religions_on_religion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_religions_on_religion_id ON public.deity_religions USING btree (religion_id);


--
-- Name: index_deity_religions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deity_religions_on_user_id ON public.deity_religions USING btree (user_id);


--
-- Name: index_document_analyses_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_analyses_on_document_id ON public.document_analyses USING btree (document_id);


--
-- Name: index_document_categories_on_document_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_categories_on_document_analysis_id ON public.document_categories USING btree (document_analysis_id);


--
-- Name: index_document_concepts_on_document_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_concepts_on_document_analysis_id ON public.document_concepts USING btree (document_analysis_id);


--
-- Name: index_document_entities_on_document_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_entities_on_document_analysis_id ON public.document_entities USING btree (document_analysis_id);


--
-- Name: index_document_entities_on_entity_type_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_entities_on_entity_type_and_entity_id ON public.document_entities USING btree (entity_type, entity_id);


--
-- Name: index_document_revisions_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_revisions_on_document_id ON public.document_revisions USING btree (document_id);


--
-- Name: index_documents_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_deleted_at_and_universe_id ON public.documents USING btree (deleted_at, universe_id);


--
-- Name: index_documents_on_deleted_at_and_universe_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_deleted_at_and_universe_id_and_user_id ON public.documents USING btree (deleted_at, universe_id, user_id);


--
-- Name: index_documents_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_universe_id ON public.documents USING btree (universe_id);


--
-- Name: index_documents_on_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_universe_id_and_deleted_at ON public.documents USING btree (universe_id, deleted_at);


--
-- Name: index_documents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_user_id ON public.documents USING btree (user_id);


--
-- Name: index_documents_on_user_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_user_id_and_deleted_at ON public.documents USING btree (user_id, deleted_at);


--
-- Name: index_floras_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_deleted_at ON public.floras USING btree (deleted_at);


--
-- Name: index_floras_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_deleted_at_and_id ON public.floras USING btree (deleted_at, id);


--
-- Name: index_floras_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_deleted_at_and_universe_id ON public.floras USING btree (deleted_at, universe_id);


--
-- Name: index_floras_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_deleted_at_and_user_id ON public.floras USING btree (deleted_at, user_id);


--
-- Name: index_floras_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_id_and_deleted_at ON public.floras USING btree (id, deleted_at);


--
-- Name: index_floras_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_universe_id ON public.floras USING btree (universe_id);


--
-- Name: index_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_user_id ON public.floras USING btree (user_id);


--
-- Name: index_floras_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floras_on_user_id_and_universe_id_and_deleted_at ON public.floras USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_foods_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_foods_on_universe_id ON public.foods USING btree (universe_id);


--
-- Name: index_foods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_foods_on_user_id ON public.foods USING btree (user_id);


--
-- Name: index_foods_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_foods_on_user_id_and_universe_id_and_deleted_at ON public.foods USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_government_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_creatures_on_creature_id ON public.government_creatures USING btree (creature_id);


--
-- Name: index_government_creatures_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_creatures_on_government_id ON public.government_creatures USING btree (government_id);


--
-- Name: index_government_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_creatures_on_user_id ON public.government_creatures USING btree (user_id);


--
-- Name: index_government_groups_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_groups_on_government_id ON public.government_groups USING btree (government_id);


--
-- Name: index_government_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_groups_on_group_id ON public.government_groups USING btree (group_id);


--
-- Name: index_government_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_groups_on_user_id ON public.government_groups USING btree (user_id);


--
-- Name: index_government_items_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_items_on_government_id ON public.government_items USING btree (government_id);


--
-- Name: index_government_items_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_items_on_item_id ON public.government_items USING btree (item_id);


--
-- Name: index_government_items_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_items_on_user_id ON public.government_items USING btree (user_id);


--
-- Name: index_government_leaders_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_leaders_on_government_id ON public.government_leaders USING btree (government_id);


--
-- Name: index_government_leaders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_leaders_on_user_id ON public.government_leaders USING btree (user_id);


--
-- Name: index_government_political_figures_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_political_figures_on_government_id ON public.government_political_figures USING btree (government_id);


--
-- Name: index_government_political_figures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_political_figures_on_user_id ON public.government_political_figures USING btree (user_id);


--
-- Name: index_government_technologies_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_technologies_on_government_id ON public.government_technologies USING btree (government_id);


--
-- Name: index_government_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_technologies_on_technology_id ON public.government_technologies USING btree (technology_id);


--
-- Name: index_government_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_government_technologies_on_user_id ON public.government_technologies USING btree (user_id);


--
-- Name: index_governments_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_deleted_at_and_id ON public.governments USING btree (deleted_at, id);


--
-- Name: index_governments_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_deleted_at_and_universe_id ON public.governments USING btree (deleted_at, universe_id);


--
-- Name: index_governments_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_deleted_at_and_user_id ON public.governments USING btree (deleted_at, user_id);


--
-- Name: index_governments_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_id_and_deleted_at ON public.governments USING btree (id, deleted_at);


--
-- Name: index_governments_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_universe_id ON public.governments USING btree (universe_id);


--
-- Name: index_governments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_user_id ON public.governments USING btree (user_id);


--
-- Name: index_governments_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_governments_on_user_id_and_universe_id_and_deleted_at ON public.governments USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_group_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_creatures_on_creature_id ON public.group_creatures USING btree (creature_id);


--
-- Name: index_group_creatures_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_creatures_on_group_id ON public.group_creatures USING btree (group_id);


--
-- Name: index_group_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_creatures_on_user_id ON public.group_creatures USING btree (user_id);


--
-- Name: index_groups_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_deleted_at ON public.groups USING btree (deleted_at);


--
-- Name: index_groups_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_deleted_at_and_id ON public.groups USING btree (deleted_at, id);


--
-- Name: index_groups_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_deleted_at_and_universe_id ON public.groups USING btree (deleted_at, universe_id);


--
-- Name: index_groups_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_deleted_at_and_user_id ON public.groups USING btree (deleted_at, user_id);


--
-- Name: index_groups_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_id_and_deleted_at ON public.groups USING btree (id, deleted_at);


--
-- Name: index_groups_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_universe_id ON public.groups USING btree (universe_id);


--
-- Name: index_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_user_id ON public.groups USING btree (user_id);


--
-- Name: index_groups_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_user_id_and_universe_id_and_deleted_at ON public.groups USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_image_uploads_on_content_type_and_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_image_uploads_on_content_type_and_content_id ON public.image_uploads USING btree (content_type, content_id);


--
-- Name: index_image_uploads_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_image_uploads_on_user_id ON public.image_uploads USING btree (user_id);


--
-- Name: index_integration_authorizations_on_application_integration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_integration_authorizations_on_application_integration_id ON public.integration_authorizations USING btree (application_integration_id);


--
-- Name: index_integration_authorizations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_integration_authorizations_on_user_id ON public.integration_authorizations USING btree (user_id);


--
-- Name: index_item_magics_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_magics_on_item_id ON public.item_magics USING btree (item_id);


--
-- Name: index_item_magics_on_magic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_magics_on_magic_id ON public.item_magics USING btree (magic_id);


--
-- Name: index_item_magics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_magics_on_user_id ON public.item_magics USING btree (user_id);


--
-- Name: index_items_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_deleted_at ON public.items USING btree (deleted_at);


--
-- Name: index_items_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_deleted_at_and_id ON public.items USING btree (deleted_at, id);


--
-- Name: index_items_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_deleted_at_and_universe_id ON public.items USING btree (deleted_at, universe_id);


--
-- Name: index_items_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_deleted_at_and_user_id ON public.items USING btree (deleted_at, user_id);


--
-- Name: index_items_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_id_and_deleted_at ON public.items USING btree (id, deleted_at);


--
-- Name: index_items_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_universe_id ON public.items USING btree (universe_id);


--
-- Name: index_items_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_user_id ON public.items USING btree (user_id);


--
-- Name: index_items_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_user_id_and_universe_id_and_deleted_at ON public.items USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_jobs_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_universe_id ON public.jobs USING btree (universe_id);


--
-- Name: index_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_user_id ON public.jobs USING btree (user_id);


--
-- Name: index_jobs_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_user_id_and_universe_id_and_deleted_at ON public.jobs USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_landmark_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_countries_on_country_id ON public.landmark_countries USING btree (country_id);


--
-- Name: index_landmark_countries_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_countries_on_landmark_id ON public.landmark_countries USING btree (landmark_id);


--
-- Name: index_landmark_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_countries_on_user_id ON public.landmark_countries USING btree (user_id);


--
-- Name: index_landmark_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_creatures_on_creature_id ON public.landmark_creatures USING btree (creature_id);


--
-- Name: index_landmark_creatures_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_creatures_on_landmark_id ON public.landmark_creatures USING btree (landmark_id);


--
-- Name: index_landmark_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_creatures_on_user_id ON public.landmark_creatures USING btree (user_id);


--
-- Name: index_landmark_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_floras_on_flora_id ON public.landmark_floras USING btree (flora_id);


--
-- Name: index_landmark_floras_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_floras_on_landmark_id ON public.landmark_floras USING btree (landmark_id);


--
-- Name: index_landmark_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_floras_on_user_id ON public.landmark_floras USING btree (user_id);


--
-- Name: index_landmark_nearby_towns_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_nearby_towns_on_landmark_id ON public.landmark_nearby_towns USING btree (landmark_id);


--
-- Name: index_landmark_nearby_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmark_nearby_towns_on_user_id ON public.landmark_nearby_towns USING btree (user_id);


--
-- Name: index_landmarks_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_deleted_at_and_id ON public.landmarks USING btree (deleted_at, id);


--
-- Name: index_landmarks_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_deleted_at_and_universe_id ON public.landmarks USING btree (deleted_at, universe_id);


--
-- Name: index_landmarks_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_deleted_at_and_user_id ON public.landmarks USING btree (deleted_at, user_id);


--
-- Name: index_landmarks_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_id_and_deleted_at ON public.landmarks USING btree (id, deleted_at);


--
-- Name: index_landmarks_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_universe_id ON public.landmarks USING btree (universe_id);


--
-- Name: index_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_user_id ON public.landmarks USING btree (user_id);


--
-- Name: index_landmarks_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_landmarks_on_user_id_and_universe_id_and_deleted_at ON public.landmarks USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_languages_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_deleted_at ON public.languages USING btree (deleted_at);


--
-- Name: index_languages_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_deleted_at_and_id ON public.languages USING btree (deleted_at, id);


--
-- Name: index_languages_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_deleted_at_and_universe_id ON public.languages USING btree (deleted_at, universe_id);


--
-- Name: index_languages_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_deleted_at_and_user_id ON public.languages USING btree (deleted_at, user_id);


--
-- Name: index_languages_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_id_and_deleted_at ON public.languages USING btree (id, deleted_at);


--
-- Name: index_languages_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_universe_id ON public.languages USING btree (universe_id);


--
-- Name: index_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_user_id ON public.languages USING btree (user_id);


--
-- Name: index_languages_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_user_id_and_universe_id_and_deleted_at ON public.languages USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_lingualisms_on_spoken_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lingualisms_on_spoken_language_id ON public.lingualisms USING btree (spoken_language_id);


--
-- Name: index_location_capital_towns_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_capital_towns_on_location_id ON public.location_capital_towns USING btree (location_id);


--
-- Name: index_location_capital_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_capital_towns_on_user_id ON public.location_capital_towns USING btree (user_id);


--
-- Name: index_location_landmarks_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_landmarks_on_landmark_id ON public.location_landmarks USING btree (landmark_id);


--
-- Name: index_location_landmarks_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_landmarks_on_location_id ON public.location_landmarks USING btree (location_id);


--
-- Name: index_location_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_landmarks_on_user_id ON public.location_landmarks USING btree (user_id);


--
-- Name: index_location_largest_towns_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_largest_towns_on_location_id ON public.location_largest_towns USING btree (location_id);


--
-- Name: index_location_largest_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_largest_towns_on_user_id ON public.location_largest_towns USING btree (user_id);


--
-- Name: index_location_notable_towns_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_notable_towns_on_location_id ON public.location_notable_towns USING btree (location_id);


--
-- Name: index_location_notable_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_location_notable_towns_on_user_id ON public.location_notable_towns USING btree (user_id);


--
-- Name: index_locations_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_deleted_at ON public.locations USING btree (deleted_at);


--
-- Name: index_locations_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_deleted_at_and_id ON public.locations USING btree (deleted_at, id);


--
-- Name: index_locations_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_deleted_at_and_universe_id ON public.locations USING btree (deleted_at, universe_id);


--
-- Name: index_locations_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_deleted_at_and_user_id ON public.locations USING btree (deleted_at, user_id);


--
-- Name: index_locations_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_id_and_deleted_at ON public.locations USING btree (id, deleted_at);


--
-- Name: index_locations_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_universe_id ON public.locations USING btree (universe_id);


--
-- Name: index_locations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_user_id ON public.locations USING btree (user_id);


--
-- Name: index_locations_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_user_id_and_universe_id_and_deleted_at ON public.locations USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_lore_believers_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_believers_on_lore_id ON public.lore_believers USING btree (lore_id);


--
-- Name: index_lore_believers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_believers_on_user_id ON public.lore_believers USING btree (user_id);


--
-- Name: index_lore_buildings_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_buildings_on_building_id ON public.lore_buildings USING btree (building_id);


--
-- Name: index_lore_buildings_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_buildings_on_lore_id ON public.lore_buildings USING btree (lore_id);


--
-- Name: index_lore_buildings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_buildings_on_user_id ON public.lore_buildings USING btree (user_id);


--
-- Name: index_lore_characters_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_characters_on_character_id ON public.lore_characters USING btree (character_id);


--
-- Name: index_lore_characters_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_characters_on_lore_id ON public.lore_characters USING btree (lore_id);


--
-- Name: index_lore_characters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_characters_on_user_id ON public.lore_characters USING btree (user_id);


--
-- Name: index_lore_conditions_on_condition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_conditions_on_condition_id ON public.lore_conditions USING btree (condition_id);


--
-- Name: index_lore_conditions_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_conditions_on_lore_id ON public.lore_conditions USING btree (lore_id);


--
-- Name: index_lore_conditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_conditions_on_user_id ON public.lore_conditions USING btree (user_id);


--
-- Name: index_lore_continents_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_continents_on_continent_id ON public.lore_continents USING btree (continent_id);


--
-- Name: index_lore_continents_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_continents_on_lore_id ON public.lore_continents USING btree (lore_id);


--
-- Name: index_lore_continents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_continents_on_user_id ON public.lore_continents USING btree (user_id);


--
-- Name: index_lore_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_countries_on_country_id ON public.lore_countries USING btree (country_id);


--
-- Name: index_lore_countries_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_countries_on_lore_id ON public.lore_countries USING btree (lore_id);


--
-- Name: index_lore_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_countries_on_user_id ON public.lore_countries USING btree (user_id);


--
-- Name: index_lore_created_traditions_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_created_traditions_on_lore_id ON public.lore_created_traditions USING btree (lore_id);


--
-- Name: index_lore_created_traditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_created_traditions_on_user_id ON public.lore_created_traditions USING btree (user_id);


--
-- Name: index_lore_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_creatures_on_creature_id ON public.lore_creatures USING btree (creature_id);


--
-- Name: index_lore_creatures_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_creatures_on_lore_id ON public.lore_creatures USING btree (lore_id);


--
-- Name: index_lore_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_creatures_on_user_id ON public.lore_creatures USING btree (user_id);


--
-- Name: index_lore_deities_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_deities_on_deity_id ON public.lore_deities USING btree (deity_id);


--
-- Name: index_lore_deities_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_deities_on_lore_id ON public.lore_deities USING btree (lore_id);


--
-- Name: index_lore_deities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_deities_on_user_id ON public.lore_deities USING btree (user_id);


--
-- Name: index_lore_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_floras_on_flora_id ON public.lore_floras USING btree (flora_id);


--
-- Name: index_lore_floras_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_floras_on_lore_id ON public.lore_floras USING btree (lore_id);


--
-- Name: index_lore_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_floras_on_user_id ON public.lore_floras USING btree (user_id);


--
-- Name: index_lore_foods_on_food_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_foods_on_food_id ON public.lore_foods USING btree (food_id);


--
-- Name: index_lore_foods_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_foods_on_lore_id ON public.lore_foods USING btree (lore_id);


--
-- Name: index_lore_foods_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_foods_on_user_id ON public.lore_foods USING btree (user_id);


--
-- Name: index_lore_governments_on_government_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_governments_on_government_id ON public.lore_governments USING btree (government_id);


--
-- Name: index_lore_governments_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_governments_on_lore_id ON public.lore_governments USING btree (lore_id);


--
-- Name: index_lore_governments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_governments_on_user_id ON public.lore_governments USING btree (user_id);


--
-- Name: index_lore_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_groups_on_group_id ON public.lore_groups USING btree (group_id);


--
-- Name: index_lore_groups_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_groups_on_lore_id ON public.lore_groups USING btree (lore_id);


--
-- Name: index_lore_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_groups_on_user_id ON public.lore_groups USING btree (user_id);


--
-- Name: index_lore_jobs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_jobs_on_job_id ON public.lore_jobs USING btree (job_id);


--
-- Name: index_lore_jobs_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_jobs_on_lore_id ON public.lore_jobs USING btree (lore_id);


--
-- Name: index_lore_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_jobs_on_user_id ON public.lore_jobs USING btree (user_id);


--
-- Name: index_lore_landmarks_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_landmarks_on_landmark_id ON public.lore_landmarks USING btree (landmark_id);


--
-- Name: index_lore_landmarks_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_landmarks_on_lore_id ON public.lore_landmarks USING btree (lore_id);


--
-- Name: index_lore_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_landmarks_on_user_id ON public.lore_landmarks USING btree (user_id);


--
-- Name: index_lore_magics_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_magics_on_lore_id ON public.lore_magics USING btree (lore_id);


--
-- Name: index_lore_magics_on_magic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_magics_on_magic_id ON public.lore_magics USING btree (magic_id);


--
-- Name: index_lore_magics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_magics_on_user_id ON public.lore_magics USING btree (user_id);


--
-- Name: index_lore_original_languages_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_original_languages_on_lore_id ON public.lore_original_languages USING btree (lore_id);


--
-- Name: index_lore_original_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_original_languages_on_user_id ON public.lore_original_languages USING btree (user_id);


--
-- Name: index_lore_planets_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_planets_on_lore_id ON public.lore_planets USING btree (lore_id);


--
-- Name: index_lore_planets_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_planets_on_planet_id ON public.lore_planets USING btree (planet_id);


--
-- Name: index_lore_planets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_planets_on_user_id ON public.lore_planets USING btree (user_id);


--
-- Name: index_lore_races_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_races_on_lore_id ON public.lore_races USING btree (lore_id);


--
-- Name: index_lore_races_on_race_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_races_on_race_id ON public.lore_races USING btree (race_id);


--
-- Name: index_lore_races_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_races_on_user_id ON public.lore_races USING btree (user_id);


--
-- Name: index_lore_related_lores_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_related_lores_on_lore_id ON public.lore_related_lores USING btree (lore_id);


--
-- Name: index_lore_related_lores_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_related_lores_on_user_id ON public.lore_related_lores USING btree (user_id);


--
-- Name: index_lore_religions_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_religions_on_lore_id ON public.lore_religions USING btree (lore_id);


--
-- Name: index_lore_religions_on_religion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_religions_on_religion_id ON public.lore_religions USING btree (religion_id);


--
-- Name: index_lore_religions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_religions_on_user_id ON public.lore_religions USING btree (user_id);


--
-- Name: index_lore_schools_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_schools_on_lore_id ON public.lore_schools USING btree (lore_id);


--
-- Name: index_lore_schools_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_schools_on_school_id ON public.lore_schools USING btree (school_id);


--
-- Name: index_lore_schools_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_schools_on_user_id ON public.lore_schools USING btree (user_id);


--
-- Name: index_lore_sports_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_sports_on_lore_id ON public.lore_sports USING btree (lore_id);


--
-- Name: index_lore_sports_on_sport_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_sports_on_sport_id ON public.lore_sports USING btree (sport_id);


--
-- Name: index_lore_sports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_sports_on_user_id ON public.lore_sports USING btree (user_id);


--
-- Name: index_lore_technologies_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_technologies_on_lore_id ON public.lore_technologies USING btree (lore_id);


--
-- Name: index_lore_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_technologies_on_technology_id ON public.lore_technologies USING btree (technology_id);


--
-- Name: index_lore_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_technologies_on_user_id ON public.lore_technologies USING btree (user_id);


--
-- Name: index_lore_towns_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_towns_on_lore_id ON public.lore_towns USING btree (lore_id);


--
-- Name: index_lore_towns_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_towns_on_town_id ON public.lore_towns USING btree (town_id);


--
-- Name: index_lore_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_towns_on_user_id ON public.lore_towns USING btree (user_id);


--
-- Name: index_lore_traditions_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_traditions_on_lore_id ON public.lore_traditions USING btree (lore_id);


--
-- Name: index_lore_traditions_on_tradition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_traditions_on_tradition_id ON public.lore_traditions USING btree (tradition_id);


--
-- Name: index_lore_traditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_traditions_on_user_id ON public.lore_traditions USING btree (user_id);


--
-- Name: index_lore_variations_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_variations_on_lore_id ON public.lore_variations USING btree (lore_id);


--
-- Name: index_lore_variations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_variations_on_user_id ON public.lore_variations USING btree (user_id);


--
-- Name: index_lore_vehicles_on_lore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_vehicles_on_lore_id ON public.lore_vehicles USING btree (lore_id);


--
-- Name: index_lore_vehicles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_vehicles_on_user_id ON public.lore_vehicles USING btree (user_id);


--
-- Name: index_lore_vehicles_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lore_vehicles_on_vehicle_id ON public.lore_vehicles USING btree (vehicle_id);


--
-- Name: index_lores_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lores_on_universe_id ON public.lores USING btree (universe_id);


--
-- Name: index_lores_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lores_on_user_id ON public.lores USING btree (user_id);


--
-- Name: index_magics_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_deleted_at ON public.magics USING btree (deleted_at);


--
-- Name: index_magics_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_deleted_at_and_id ON public.magics USING btree (deleted_at, id);


--
-- Name: index_magics_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_deleted_at_and_universe_id ON public.magics USING btree (deleted_at, universe_id);


--
-- Name: index_magics_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_deleted_at_and_user_id ON public.magics USING btree (deleted_at, user_id);


--
-- Name: index_magics_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_id_and_deleted_at ON public.magics USING btree (id, deleted_at);


--
-- Name: index_magics_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_universe_id ON public.magics USING btree (universe_id);


--
-- Name: index_magics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_user_id ON public.magics USING btree (user_id);


--
-- Name: index_magics_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magics_on_user_id_and_universe_id_and_deleted_at ON public.magics USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_notice_dismissals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notice_dismissals_on_user_id ON public.notice_dismissals USING btree (user_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON public.notifications USING btree (user_id);


--
-- Name: index_page_collection_followings_on_page_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_followings_on_page_collection_id ON public.page_collection_followings USING btree (page_collection_id);


--
-- Name: index_page_collection_followings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_followings_on_user_id ON public.page_collection_followings USING btree (user_id);


--
-- Name: index_page_collection_reports_on_page_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_reports_on_page_collection_id ON public.page_collection_reports USING btree (page_collection_id);


--
-- Name: index_page_collection_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_reports_on_user_id ON public.page_collection_reports USING btree (user_id);


--
-- Name: index_page_collection_submissions_on_page_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_submissions_on_page_collection_id ON public.page_collection_submissions USING btree (page_collection_id);


--
-- Name: index_page_collection_submissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collection_submissions_on_user_id ON public.page_collection_submissions USING btree (user_id);


--
-- Name: index_page_collections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_collections_on_user_id ON public.page_collections USING btree (user_id);


--
-- Name: index_page_references_on_attribute_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_references_on_attribute_field_id ON public.page_references USING btree (attribute_field_id);


--
-- Name: index_page_settings_overrides_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_settings_overrides_on_user_id ON public.page_settings_overrides USING btree (user_id);


--
-- Name: index_page_tags_on_page_type_and_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_tags_on_page_type_and_page_id ON public.page_tags USING btree (page_type, page_id);


--
-- Name: index_page_tags_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_tags_on_user_id ON public.page_tags USING btree (user_id);


--
-- Name: index_page_tags_on_user_id_and_page_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_tags_on_user_id_and_page_type ON public.page_tags USING btree (user_id, page_type);


--
-- Name: index_paypal_invoices_on_page_unlock_promo_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paypal_invoices_on_page_unlock_promo_code_id ON public.paypal_invoices USING btree (page_unlock_promo_code_id);


--
-- Name: index_paypal_invoices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paypal_invoices_on_user_id ON public.paypal_invoices USING btree (user_id);


--
-- Name: index_planet_continents_on_continent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_continents_on_continent_id ON public.planet_continents USING btree (continent_id);


--
-- Name: index_planet_continents_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_continents_on_planet_id ON public.planet_continents USING btree (planet_id);


--
-- Name: index_planet_continents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_continents_on_user_id ON public.planet_continents USING btree (user_id);


--
-- Name: index_planet_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_countries_on_country_id ON public.planet_countries USING btree (country_id);


--
-- Name: index_planet_countries_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_countries_on_planet_id ON public.planet_countries USING btree (planet_id);


--
-- Name: index_planet_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_countries_on_user_id ON public.planet_countries USING btree (user_id);


--
-- Name: index_planet_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_creatures_on_creature_id ON public.planet_creatures USING btree (creature_id);


--
-- Name: index_planet_creatures_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_creatures_on_planet_id ON public.planet_creatures USING btree (planet_id);


--
-- Name: index_planet_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_creatures_on_user_id ON public.planet_creatures USING btree (user_id);


--
-- Name: index_planet_deities_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_deities_on_deity_id ON public.planet_deities USING btree (deity_id);


--
-- Name: index_planet_deities_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_deities_on_planet_id ON public.planet_deities USING btree (planet_id);


--
-- Name: index_planet_deities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_deities_on_user_id ON public.planet_deities USING btree (user_id);


--
-- Name: index_planet_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_floras_on_flora_id ON public.planet_floras USING btree (flora_id);


--
-- Name: index_planet_floras_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_floras_on_planet_id ON public.planet_floras USING btree (planet_id);


--
-- Name: index_planet_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_floras_on_user_id ON public.planet_floras USING btree (user_id);


--
-- Name: index_planet_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_groups_on_group_id ON public.planet_groups USING btree (group_id);


--
-- Name: index_planet_groups_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_groups_on_planet_id ON public.planet_groups USING btree (planet_id);


--
-- Name: index_planet_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_groups_on_user_id ON public.planet_groups USING btree (user_id);


--
-- Name: index_planet_landmarks_on_landmark_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_landmarks_on_landmark_id ON public.planet_landmarks USING btree (landmark_id);


--
-- Name: index_planet_landmarks_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_landmarks_on_planet_id ON public.planet_landmarks USING btree (planet_id);


--
-- Name: index_planet_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_landmarks_on_user_id ON public.planet_landmarks USING btree (user_id);


--
-- Name: index_planet_languages_on_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_languages_on_language_id ON public.planet_languages USING btree (language_id);


--
-- Name: index_planet_languages_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_languages_on_planet_id ON public.planet_languages USING btree (planet_id);


--
-- Name: index_planet_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_languages_on_user_id ON public.planet_languages USING btree (user_id);


--
-- Name: index_planet_locations_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_locations_on_location_id ON public.planet_locations USING btree (location_id);


--
-- Name: index_planet_locations_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_locations_on_planet_id ON public.planet_locations USING btree (planet_id);


--
-- Name: index_planet_locations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_locations_on_user_id ON public.planet_locations USING btree (user_id);


--
-- Name: index_planet_nearby_planets_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_nearby_planets_on_planet_id ON public.planet_nearby_planets USING btree (planet_id);


--
-- Name: index_planet_nearby_planets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_nearby_planets_on_user_id ON public.planet_nearby_planets USING btree (user_id);


--
-- Name: index_planet_races_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_races_on_planet_id ON public.planet_races USING btree (planet_id);


--
-- Name: index_planet_races_on_race_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_races_on_race_id ON public.planet_races USING btree (race_id);


--
-- Name: index_planet_races_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_races_on_user_id ON public.planet_races USING btree (user_id);


--
-- Name: index_planet_religions_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_religions_on_planet_id ON public.planet_religions USING btree (planet_id);


--
-- Name: index_planet_religions_on_religion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_religions_on_religion_id ON public.planet_religions USING btree (religion_id);


--
-- Name: index_planet_religions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_religions_on_user_id ON public.planet_religions USING btree (user_id);


--
-- Name: index_planet_towns_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_towns_on_planet_id ON public.planet_towns USING btree (planet_id);


--
-- Name: index_planet_towns_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_towns_on_town_id ON public.planet_towns USING btree (town_id);


--
-- Name: index_planet_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planet_towns_on_user_id ON public.planet_towns USING btree (user_id);


--
-- Name: index_planets_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_deleted_at_and_id ON public.planets USING btree (deleted_at, id);


--
-- Name: index_planets_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_deleted_at_and_universe_id ON public.planets USING btree (deleted_at, universe_id);


--
-- Name: index_planets_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_deleted_at_and_user_id ON public.planets USING btree (deleted_at, user_id);


--
-- Name: index_planets_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_id_and_deleted_at ON public.planets USING btree (id, deleted_at);


--
-- Name: index_planets_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_universe_id ON public.planets USING btree (universe_id);


--
-- Name: index_planets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_user_id ON public.planets USING btree (user_id);


--
-- Name: index_planets_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_planets_on_user_id_and_universe_id_and_deleted_at ON public.planets USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_promotions_on_page_unlock_promo_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promotions_on_page_unlock_promo_code_id ON public.promotions USING btree (page_unlock_promo_code_id);


--
-- Name: index_promotions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promotions_on_user_id ON public.promotions USING btree (user_id);


--
-- Name: index_promotions_on_user_id_and_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promotions_on_user_id_and_expires_at ON public.promotions USING btree (user_id, expires_at);


--
-- Name: index_races_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_deleted_at ON public.races USING btree (deleted_at);


--
-- Name: index_races_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_deleted_at_and_id ON public.races USING btree (deleted_at, id);


--
-- Name: index_races_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_deleted_at_and_universe_id ON public.races USING btree (deleted_at, universe_id);


--
-- Name: index_races_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_deleted_at_and_user_id ON public.races USING btree (deleted_at, user_id);


--
-- Name: index_races_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_id_and_deleted_at ON public.races USING btree (id, deleted_at);


--
-- Name: index_races_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_races_on_user_id_and_universe_id_and_deleted_at ON public.races USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_raffle_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_raffle_entries_on_user_id ON public.raffle_entries USING btree (user_id);


--
-- Name: index_referral_codes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_referral_codes_on_user_id ON public.referral_codes USING btree (user_id);


--
-- Name: index_religion_deities_on_deity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religion_deities_on_deity_id ON public.religion_deities USING btree (deity_id);


--
-- Name: index_religion_deities_on_religion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religion_deities_on_religion_id ON public.religion_deities USING btree (religion_id);


--
-- Name: index_religion_deities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religion_deities_on_user_id ON public.religion_deities USING btree (user_id);


--
-- Name: index_religions_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_deleted_at ON public.religions USING btree (deleted_at);


--
-- Name: index_religions_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_deleted_at_and_id ON public.religions USING btree (deleted_at, id);


--
-- Name: index_religions_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_deleted_at_and_universe_id ON public.religions USING btree (deleted_at, universe_id);


--
-- Name: index_religions_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_deleted_at_and_user_id ON public.religions USING btree (deleted_at, user_id);


--
-- Name: index_religions_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_id_and_deleted_at ON public.religions USING btree (id, deleted_at);


--
-- Name: index_religions_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_universe_id ON public.religions USING btree (universe_id);


--
-- Name: index_religions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_user_id ON public.religions USING btree (user_id);


--
-- Name: index_religions_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_religions_on_user_id_and_universe_id_and_deleted_at ON public.religions USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_scenes_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_deleted_at ON public.scenes USING btree (deleted_at);


--
-- Name: index_scenes_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_deleted_at_and_id ON public.scenes USING btree (deleted_at, id);


--
-- Name: index_scenes_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_deleted_at_and_universe_id ON public.scenes USING btree (deleted_at, universe_id);


--
-- Name: index_scenes_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_deleted_at_and_user_id ON public.scenes USING btree (deleted_at, user_id);


--
-- Name: index_scenes_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_id_and_deleted_at ON public.scenes USING btree (id, deleted_at);


--
-- Name: index_scenes_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_universe_id ON public.scenes USING btree (universe_id);


--
-- Name: index_scenes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_user_id ON public.scenes USING btree (user_id);


--
-- Name: index_scenes_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenes_on_user_id_and_universe_id_and_deleted_at ON public.scenes USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_schools_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_universe_id ON public.schools USING btree (universe_id);


--
-- Name: index_schools_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_user_id ON public.schools USING btree (user_id);


--
-- Name: index_schools_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_user_id_and_universe_id_and_deleted_at ON public.schools USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_secondary_content_page_share; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_secondary_content_page_share ON public.content_page_shares USING btree (secondary_content_page_type, secondary_content_page_id);


--
-- Name: index_share_comments_on_content_page_share_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_share_comments_on_content_page_share_id ON public.share_comments USING btree (content_page_share_id);


--
-- Name: index_share_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_share_comments_on_user_id ON public.share_comments USING btree (user_id);


--
-- Name: index_sports_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sports_on_universe_id ON public.sports USING btree (universe_id);


--
-- Name: index_sports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sports_on_user_id ON public.sports USING btree (user_id);


--
-- Name: index_sports_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sports_on_user_id_and_universe_id_and_deleted_at ON public.sports USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_subscriptions_on_billing_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_billing_plan_id ON public.subscriptions USING btree (billing_plan_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_user_id ON public.subscriptions USING btree (user_id);


--
-- Name: index_subscriptions_on_user_id_and_start_date_and_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_user_id_and_start_date_and_end_date ON public.subscriptions USING btree (user_id, start_date, end_date);


--
-- Name: index_technologies_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_deleted_at_and_id ON public.technologies USING btree (deleted_at, id);


--
-- Name: index_technologies_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_deleted_at_and_universe_id ON public.technologies USING btree (deleted_at, universe_id);


--
-- Name: index_technologies_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_deleted_at_and_user_id ON public.technologies USING btree (deleted_at, user_id);


--
-- Name: index_technologies_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_id_and_deleted_at ON public.technologies USING btree (id, deleted_at);


--
-- Name: index_technologies_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_universe_id ON public.technologies USING btree (universe_id);


--
-- Name: index_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_user_id ON public.technologies USING btree (user_id);


--
-- Name: index_technologies_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technologies_on_user_id_and_universe_id_and_deleted_at ON public.technologies USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_technology_characters_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_characters_on_character_id ON public.technology_characters USING btree (character_id);


--
-- Name: index_technology_characters_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_characters_on_technology_id ON public.technology_characters USING btree (technology_id);


--
-- Name: index_technology_characters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_characters_on_user_id ON public.technology_characters USING btree (user_id);


--
-- Name: index_technology_child_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_child_technologies_on_technology_id ON public.technology_child_technologies USING btree (technology_id);


--
-- Name: index_technology_child_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_child_technologies_on_user_id ON public.technology_child_technologies USING btree (user_id);


--
-- Name: index_technology_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_countries_on_country_id ON public.technology_countries USING btree (country_id);


--
-- Name: index_technology_countries_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_countries_on_technology_id ON public.technology_countries USING btree (technology_id);


--
-- Name: index_technology_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_countries_on_user_id ON public.technology_countries USING btree (user_id);


--
-- Name: index_technology_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_creatures_on_creature_id ON public.technology_creatures USING btree (creature_id);


--
-- Name: index_technology_creatures_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_creatures_on_technology_id ON public.technology_creatures USING btree (technology_id);


--
-- Name: index_technology_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_creatures_on_user_id ON public.technology_creatures USING btree (user_id);


--
-- Name: index_technology_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_groups_on_group_id ON public.technology_groups USING btree (group_id);


--
-- Name: index_technology_groups_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_groups_on_technology_id ON public.technology_groups USING btree (technology_id);


--
-- Name: index_technology_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_groups_on_user_id ON public.technology_groups USING btree (user_id);


--
-- Name: index_technology_magics_on_magic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_magics_on_magic_id ON public.technology_magics USING btree (magic_id);


--
-- Name: index_technology_magics_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_magics_on_technology_id ON public.technology_magics USING btree (technology_id);


--
-- Name: index_technology_magics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_magics_on_user_id ON public.technology_magics USING btree (user_id);


--
-- Name: index_technology_parent_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_parent_technologies_on_technology_id ON public.technology_parent_technologies USING btree (technology_id);


--
-- Name: index_technology_parent_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_parent_technologies_on_user_id ON public.technology_parent_technologies USING btree (user_id);


--
-- Name: index_technology_planets_on_planet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_planets_on_planet_id ON public.technology_planets USING btree (planet_id);


--
-- Name: index_technology_planets_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_planets_on_technology_id ON public.technology_planets USING btree (technology_id);


--
-- Name: index_technology_planets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_planets_on_user_id ON public.technology_planets USING btree (user_id);


--
-- Name: index_technology_related_technologies_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_related_technologies_on_technology_id ON public.technology_related_technologies USING btree (technology_id);


--
-- Name: index_technology_related_technologies_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_related_technologies_on_user_id ON public.technology_related_technologies USING btree (user_id);


--
-- Name: index_technology_towns_on_technology_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_towns_on_technology_id ON public.technology_towns USING btree (technology_id);


--
-- Name: index_technology_towns_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_towns_on_town_id ON public.technology_towns USING btree (town_id);


--
-- Name: index_technology_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technology_towns_on_user_id ON public.technology_towns USING btree (user_id);


--
-- Name: index_thredded_categories_on_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_categories_on_messageboard_id ON public.thredded_categories USING btree (messageboard_id);


--
-- Name: index_thredded_categories_on_messageboard_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_categories_on_messageboard_id_and_slug ON public.thredded_categories USING btree (messageboard_id, slug);


--
-- Name: index_thredded_messageboard_users_for_recently_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_messageboard_users_for_recently_active ON public.thredded_messageboard_users USING btree (thredded_messageboard_id, last_seen_at);


--
-- Name: index_thredded_messageboard_users_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_messageboard_users_primary ON public.thredded_messageboard_users USING btree (thredded_messageboard_id, thredded_user_detail_id);


--
-- Name: index_thredded_messageboards_on_messageboard_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_messageboards_on_messageboard_group_id ON public.thredded_messageboards USING btree (messageboard_group_id);


--
-- Name: index_thredded_messageboards_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_messageboards_on_slug ON public.thredded_messageboards USING btree (slug);


--
-- Name: index_thredded_moderation_records_for_display; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_moderation_records_for_display ON public.thredded_post_moderation_records USING btree (messageboard_id, created_at DESC);


--
-- Name: index_thredded_posts_for_display; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_for_display ON public.thredded_posts USING btree (moderation_state, updated_at);


--
-- Name: index_thredded_posts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_deleted_at ON public.thredded_posts USING btree (deleted_at);


--
-- Name: index_thredded_posts_on_deleted_at_and_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_deleted_at_and_messageboard_id ON public.thredded_posts USING btree (deleted_at, messageboard_id);


--
-- Name: index_thredded_posts_on_deleted_at_and_postable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_deleted_at_and_postable_id ON public.thredded_posts USING btree (deleted_at, postable_id);


--
-- Name: index_thredded_posts_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_deleted_at_and_user_id ON public.thredded_posts USING btree (deleted_at, user_id);


--
-- Name: index_thredded_posts_on_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_messageboard_id ON public.thredded_posts USING btree (messageboard_id);


--
-- Name: index_thredded_posts_on_postable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_postable_id ON public.thredded_posts USING btree (postable_id);


--
-- Name: index_thredded_posts_on_postable_id_and_postable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_postable_id_and_postable_type ON public.thredded_posts USING btree (postable_id);


--
-- Name: index_thredded_posts_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_tsv ON public.thredded_posts USING gin (tsv);


--
-- Name: index_thredded_posts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_posts_on_user_id ON public.thredded_posts USING btree (user_id);


--
-- Name: index_thredded_private_posts_on_postable_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_private_posts_on_postable_id_and_created_at ON public.thredded_private_posts USING btree (postable_id, created_at);


--
-- Name: index_thredded_private_topics_on_hash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_private_topics_on_hash_id ON public.thredded_private_topics USING btree (hash_id);


--
-- Name: index_thredded_private_topics_on_last_post_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_private_topics_on_last_post_at ON public.thredded_private_topics USING btree (last_post_at);


--
-- Name: index_thredded_private_topics_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_private_topics_on_slug ON public.thredded_private_topics USING btree (slug);


--
-- Name: index_thredded_private_users_on_private_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_private_users_on_private_topic_id ON public.thredded_private_users USING btree (private_topic_id);


--
-- Name: index_thredded_private_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_private_users_on_user_id ON public.thredded_private_users USING btree (user_id);


--
-- Name: index_thredded_topic_categories_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topic_categories_on_category_id ON public.thredded_topic_categories USING btree (category_id);


--
-- Name: index_thredded_topic_categories_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topic_categories_on_topic_id ON public.thredded_topic_categories USING btree (topic_id);


--
-- Name: index_thredded_topics_for_display; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_for_display ON public.thredded_topics USING btree (moderation_state, sticky DESC, updated_at DESC);


--
-- Name: index_thredded_topics_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_deleted_at ON public.thredded_topics USING btree (deleted_at);


--
-- Name: index_thredded_topics_on_deleted_at_and_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_deleted_at_and_messageboard_id ON public.thredded_topics USING btree (deleted_at, messageboard_id);


--
-- Name: index_thredded_topics_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_deleted_at_and_user_id ON public.thredded_topics USING btree (deleted_at, user_id);


--
-- Name: index_thredded_topics_on_hash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_hash_id ON public.thredded_topics USING btree (hash_id);


--
-- Name: index_thredded_topics_on_last_post_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_last_post_at ON public.thredded_topics USING btree (last_post_at);


--
-- Name: index_thredded_topics_on_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_messageboard_id ON public.thredded_topics USING btree (messageboard_id);


--
-- Name: index_thredded_topics_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_topics_on_slug ON public.thredded_topics USING btree (slug);


--
-- Name: index_thredded_topics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_topics_on_user_id ON public.thredded_topics USING btree (user_id);


--
-- Name: index_thredded_user_details_for_moderations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_user_details_for_moderations ON public.thredded_user_details USING btree (moderation_state, moderation_state_changed_at DESC);


--
-- Name: index_thredded_user_details_on_latest_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_user_details_on_latest_activity_at ON public.thredded_user_details USING btree (latest_activity_at);


--
-- Name: index_thredded_user_details_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_user_details_on_user_id ON public.thredded_user_details USING btree (user_id);


--
-- Name: index_thredded_user_post_notifications_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_user_post_notifications_on_post_id ON public.thredded_user_post_notifications USING btree (post_id);


--
-- Name: index_thredded_user_post_notifications_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_user_post_notifications_on_user_id_and_post_id ON public.thredded_user_post_notifications USING btree (user_id, post_id);


--
-- Name: index_thredded_user_preferences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_thredded_user_preferences_on_user_id ON public.thredded_user_preferences USING btree (user_id);


--
-- Name: index_thredded_user_topic_read_states_on_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thredded_user_topic_read_states_on_messageboard_id ON public.thredded_user_topic_read_states USING btree (messageboard_id);


--
-- Name: index_timeline_event_entities_on_entity_type_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timeline_event_entities_on_entity_type_and_entity_id ON public.timeline_event_entities USING btree (entity_type, entity_id);


--
-- Name: index_timeline_event_entities_on_timeline_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timeline_event_entities_on_timeline_event_id ON public.timeline_event_entities USING btree (timeline_event_id);


--
-- Name: index_timeline_events_on_timeline_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timeline_events_on_timeline_id ON public.timeline_events USING btree (timeline_id);


--
-- Name: index_timelines_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timelines_on_deleted_at_and_user_id ON public.timelines USING btree (deleted_at, user_id);


--
-- Name: index_timelines_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timelines_on_universe_id ON public.timelines USING btree (universe_id);


--
-- Name: index_timelines_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timelines_on_user_id ON public.timelines USING btree (user_id);


--
-- Name: index_town_citizens_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_citizens_on_town_id ON public.town_citizens USING btree (town_id);


--
-- Name: index_town_citizens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_citizens_on_user_id ON public.town_citizens USING btree (user_id);


--
-- Name: index_town_countries_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_countries_on_country_id ON public.town_countries USING btree (country_id);


--
-- Name: index_town_countries_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_countries_on_town_id ON public.town_countries USING btree (town_id);


--
-- Name: index_town_countries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_countries_on_user_id ON public.town_countries USING btree (user_id);


--
-- Name: index_town_creatures_on_creature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_creatures_on_creature_id ON public.town_creatures USING btree (creature_id);


--
-- Name: index_town_creatures_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_creatures_on_town_id ON public.town_creatures USING btree (town_id);


--
-- Name: index_town_creatures_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_creatures_on_user_id ON public.town_creatures USING btree (user_id);


--
-- Name: index_town_floras_on_flora_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_floras_on_flora_id ON public.town_floras USING btree (flora_id);


--
-- Name: index_town_floras_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_floras_on_town_id ON public.town_floras USING btree (town_id);


--
-- Name: index_town_floras_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_floras_on_user_id ON public.town_floras USING btree (user_id);


--
-- Name: index_town_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_groups_on_group_id ON public.town_groups USING btree (group_id);


--
-- Name: index_town_groups_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_groups_on_town_id ON public.town_groups USING btree (town_id);


--
-- Name: index_town_groups_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_groups_on_user_id ON public.town_groups USING btree (user_id);


--
-- Name: index_town_languages_on_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_languages_on_language_id ON public.town_languages USING btree (language_id);


--
-- Name: index_town_languages_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_languages_on_town_id ON public.town_languages USING btree (town_id);


--
-- Name: index_town_languages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_languages_on_user_id ON public.town_languages USING btree (user_id);


--
-- Name: index_town_nearby_landmarks_on_town_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_nearby_landmarks_on_town_id ON public.town_nearby_landmarks USING btree (town_id);


--
-- Name: index_town_nearby_landmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_town_nearby_landmarks_on_user_id ON public.town_nearby_landmarks USING btree (user_id);


--
-- Name: index_towns_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_deleted_at_and_id ON public.towns USING btree (deleted_at, id);


--
-- Name: index_towns_on_deleted_at_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_deleted_at_and_universe_id ON public.towns USING btree (deleted_at, universe_id);


--
-- Name: index_towns_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_deleted_at_and_user_id ON public.towns USING btree (deleted_at, user_id);


--
-- Name: index_towns_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_id_and_deleted_at ON public.towns USING btree (id, deleted_at);


--
-- Name: index_towns_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_universe_id ON public.towns USING btree (universe_id);


--
-- Name: index_towns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_user_id ON public.towns USING btree (user_id);


--
-- Name: index_towns_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_towns_on_user_id_and_universe_id_and_deleted_at ON public.towns USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_traditions_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traditions_on_universe_id ON public.traditions USING btree (universe_id);


--
-- Name: index_traditions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traditions_on_user_id ON public.traditions USING btree (user_id);


--
-- Name: index_traditions_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traditions_on_user_id_and_universe_id_and_deleted_at ON public.traditions USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_universes_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_deleted_at ON public.universes USING btree (deleted_at);


--
-- Name: index_universes_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_deleted_at_and_id ON public.universes USING btree (deleted_at, id);


--
-- Name: index_universes_on_deleted_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_deleted_at_and_user_id ON public.universes USING btree (deleted_at, user_id);


--
-- Name: index_universes_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_id_and_deleted_at ON public.universes USING btree (id, deleted_at);


--
-- Name: index_universes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_user_id ON public.universes USING btree (user_id);


--
-- Name: index_user_blockings_on_blocked_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_blockings_on_blocked_user_id ON public.user_blockings USING btree (blocked_user_id);


--
-- Name: index_user_blockings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_blockings_on_user_id ON public.user_blockings USING btree (user_id);


--
-- Name: index_user_content_type_activators_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_content_type_activators_on_user_id ON public.user_content_type_activators USING btree (user_id);


--
-- Name: index_user_followings_on_followed_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_followings_on_followed_user_id ON public.user_followings USING btree (followed_user_id);


--
-- Name: index_user_followings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_followings_on_user_id ON public.user_followings USING btree (user_id);


--
-- Name: index_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_at ON public.users USING btree (deleted_at);


--
-- Name: index_users_on_deleted_at_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_at_and_id ON public.users USING btree (deleted_at, id);


--
-- Name: index_users_on_deleted_at_and_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_at_and_username ON public.users USING btree (deleted_at, username);


--
-- Name: index_users_on_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_id_and_deleted_at ON public.users USING btree (id, deleted_at);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_vehicles_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_universe_id ON public.vehicles USING btree (universe_id);


--
-- Name: index_vehicles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_user_id ON public.vehicles USING btree (user_id);


--
-- Name: index_vehicles_on_user_id_and_universe_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_user_id_and_universe_id_and_deleted_at ON public.vehicles USING btree (user_id, universe_id, deleted_at);


--
-- Name: index_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_user_id ON public.votes USING btree (user_id);


--
-- Name: index_votes_on_votable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_id ON public.votes USING btree (votable_id);


--
-- Name: page_reference_referenced_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX page_reference_referenced_page ON public.page_references USING btree (referenced_page_type, referenced_page_id);


--
-- Name: page_reference_referencing_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX page_reference_referencing_page ON public.page_references USING btree (referencing_page_type, referencing_page_id);


--
-- Name: polycontent_collection_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX polycontent_collection_index ON public.page_collection_submissions USING btree (content_type, content_id);


--
-- Name: special_field_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX special_field_type_index ON public.attribute_fields USING btree (user_id, attribute_category_id, field_type, deleted_at);


--
-- Name: temporary_migration_lookup_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX temporary_migration_lookup_index ON public.attribute_fields USING btree (user_id, attribute_category_id, label, old_column_source, field_type);


--
-- Name: temporary_migration_lookup_with_deleted_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX temporary_migration_lookup_with_deleted_index ON public.attribute_fields USING btree (user_id, attribute_category_id, label, old_column_source, field_type, deleted_at);


--
-- Name: thredded_categories_name_ci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thredded_categories_name_ci ON public.thredded_categories USING btree (lower(name) text_pattern_ops);


--
-- Name: thredded_messageboard_notifications_for_followed_topics_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_messageboard_notifications_for_followed_topics_unique ON public.thredded_messageboard_notifications_for_followed_topics USING btree (user_id, messageboard_id, notifier_key);


--
-- Name: thredded_notifications_for_followed_topics_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_notifications_for_followed_topics_unique ON public.thredded_notifications_for_followed_topics USING btree (user_id, notifier_key);


--
-- Name: thredded_notifications_for_private_topics_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_notifications_for_private_topics_unique ON public.thredded_notifications_for_private_topics USING btree (user_id, notifier_key);


--
-- Name: thredded_posts_content_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thredded_posts_content_fts ON public.thredded_posts USING gist (to_tsvector('english'::regconfig, content));


--
-- Name: thredded_topics_title_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thredded_topics_title_fts ON public.thredded_topics USING gist (to_tsvector('english'::regconfig, title));


--
-- Name: thredded_user_messageboard_preferences_user_id_messageboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_user_messageboard_preferences_user_id_messageboard_id ON public.thredded_user_messageboard_preferences USING btree (user_id, messageboard_id);


--
-- Name: thredded_user_private_topic_read_states_user_postable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_user_private_topic_read_states_user_postable ON public.thredded_user_private_topic_read_states USING btree (user_id, postable_id);


--
-- Name: thredded_user_topic_follows_user_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_user_topic_follows_user_topic ON public.thredded_user_topic_follows USING btree (user_id, topic_id);


--
-- Name: thredded_user_topic_read_states_user_messageboard; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thredded_user_topic_read_states_user_messageboard ON public.thredded_user_topic_read_states USING btree (user_id, messageboard_id);


--
-- Name: thredded_user_topic_read_states_user_postable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thredded_user_topic_read_states_user_postable ON public.thredded_user_topic_read_states USING btree (user_id, postable_id);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.thredded_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.english', 'title', 'content');


--
-- Name: fk_rails_00220cc8c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_towns
    ADD CONSTRAINT fk_rails_00220cc8c9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_002cf621b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governments
    ADD CONSTRAINT fk_rails_002cf621b9 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_00318cb492; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_landmarks
    ADD CONSTRAINT fk_rails_00318cb492 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_0097966fec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_floras
    ADD CONSTRAINT fk_rails_0097966fec FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_00bd3abc80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_parent_technologies
    ADD CONSTRAINT fk_rails_00bd3abc80 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_03743e2c36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmarks
    ADD CONSTRAINT fk_rails_03743e2c36 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_04dad67c1d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_creatures
    ADD CONSTRAINT fk_rails_04dad67c1d FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_052dc245af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_052dc245af FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_0684f54677; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_towns
    ADD CONSTRAINT fk_rails_0684f54677 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_06e42c62f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_users
    ADD CONSTRAINT fk_rails_06e42c62f5 FOREIGN KEY (thredded_user_detail_id) REFERENCES public.thredded_user_details(id) ON DELETE CASCADE;


--
-- Name: fk_rails_070dd312ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_planets
    ADD CONSTRAINT fk_rails_070dd312ae FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_079ace43b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_countries
    ADD CONSTRAINT fk_rails_079ace43b3 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_07c96d3006; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_reports
    ADD CONSTRAINT fk_rails_07c96d3006 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_09023d7126; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_governments
    ADD CONSTRAINT fk_rails_09023d7126 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_090b2e9e0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT fk_rails_090b2e9e0c FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_093531ac56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_creatures
    ADD CONSTRAINT fk_rails_093531ac56 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_09d0d51048; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_conditions
    ADD CONSTRAINT fk_rails_09d0d51048 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_0a7e174039; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_schools
    ADD CONSTRAINT fk_rails_0a7e174039 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_0af3bcda2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_creatures
    ADD CONSTRAINT fk_rails_0af3bcda2d FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_0b36232f0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_integrations
    ADD CONSTRAINT fk_rails_0b36232f0d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_0b7e25f240; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_creatures
    ADD CONSTRAINT fk_rails_0b7e25f240 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_0bee32acfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_followings
    ADD CONSTRAINT fk_rails_0bee32acfe FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_0e20633e3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_magics
    ADD CONSTRAINT fk_rails_0e20633e3c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_0e6faa54e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paypal_invoices
    ADD CONSTRAINT fk_rails_0e6faa54e5 FOREIGN KEY (page_unlock_promo_code_id) REFERENCES public.page_unlock_promo_codes(id);


--
-- Name: fk_rails_10ad90c4a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_groups
    ADD CONSTRAINT fk_rails_10ad90c4a1 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_10be78ad8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_groups
    ADD CONSTRAINT fk_rails_10be78ad8b FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_10ee16fd87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_groups
    ADD CONSTRAINT fk_rails_10ee16fd87 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_13b750add5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_races
    ADD CONSTRAINT fk_rails_13b750add5 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_144415d98c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_children
    ADD CONSTRAINT fk_rails_144415d98c FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_15d8dec892; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_believers
    ADD CONSTRAINT fk_rails_15d8dec892 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_16b5bd0371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_religions
    ADD CONSTRAINT fk_rails_16b5bd0371 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_16cf1be6e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_races
    ADD CONSTRAINT fk_rails_16cf1be6e3 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_16d59014db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_landmarks
    ADD CONSTRAINT fk_rails_16d59014db FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_16e5446872; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_magics
    ADD CONSTRAINT fk_rails_16e5446872 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: fk_rails_16ea4089a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT fk_rails_16ea4089a3 FOREIGN KEY (page_unlock_promo_code_id) REFERENCES public.page_unlock_promo_codes(id);


--
-- Name: fk_rails_1710730113; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_languages
    ADD CONSTRAINT fk_rails_1710730113 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1712b6a5c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT fk_rails_1712b6a5c9 FOREIGN KEY (timeline_id) REFERENCES public.timelines(id);


--
-- Name: fk_rails_18b09e08ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_religions
    ADD CONSTRAINT fk_rails_18b09e08ff FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1a8b3a567e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_creatures
    ADD CONSTRAINT fk_rails_1a8b3a567e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1b2019c8b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religion_deities
    ADD CONSTRAINT fk_rails_1b2019c8b8 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_1bd3a314e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_political_figures
    ADD CONSTRAINT fk_rails_1bd3a314e6 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_1c791f7ea9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_races
    ADD CONSTRAINT fk_rails_1c791f7ea9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1c9193771e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_floras
    ADD CONSTRAINT fk_rails_1c9193771e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1d74ef3ca4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_comments
    ADD CONSTRAINT fk_rails_1d74ef3ca4 FOREIGN KEY (content_page_share_id) REFERENCES public.content_page_shares(id);


--
-- Name: fk_rails_1e4fd04022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_submissions
    ADD CONSTRAINT fk_rails_1e4fd04022 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1ec453531c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_bordering_countries
    ADD CONSTRAINT fk_rails_1ec453531c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_1f08fe24c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_siblings
    ADD CONSTRAINT fk_rails_1f08fe24c9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2021c47835; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_languages
    ADD CONSTRAINT fk_rails_2021c47835 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_20d46a1626; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_countries
    ADD CONSTRAINT fk_rails_20d46a1626 FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_21ba6952ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_technologies
    ADD CONSTRAINT fk_rails_21ba6952ad FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_22bddd59b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_technologies
    ADD CONSTRAINT fk_rails_22bddd59b6 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_22db33f2f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_governments
    ADD CONSTRAINT fk_rails_22db33f2f2 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_23cb02a0f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_groups
    ADD CONSTRAINT fk_rails_23cb02a0f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_25a8c33372; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_child_technologies
    ADD CONSTRAINT fk_rails_25a8c33372 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_263939338d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_relics
    ADD CONSTRAINT fk_rails_263939338d FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_271bb94de2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_floras
    ADD CONSTRAINT fk_rails_271bb94de2 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_278fe77f11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_enemies
    ADD CONSTRAINT fk_rails_278fe77f11 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_28ac437043; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_characters
    ADD CONSTRAINT fk_rails_28ac437043 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_2920622146; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_landmarks
    ADD CONSTRAINT fk_rails_2920622146 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_29a76fef54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_abilities
    ADD CONSTRAINT fk_rails_29a76fef54 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2a46f510ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_groups
    ADD CONSTRAINT fk_rails_2a46f510ac FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_2af454f50c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governments
    ADD CONSTRAINT fk_rails_2af454f50c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2b1bf28f5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_countries
    ADD CONSTRAINT fk_rails_2b1bf28f5d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2b32e97849; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_friends
    ADD CONSTRAINT fk_rails_2b32e97849 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_2b94ac124c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_landmarks
    ADD CONSTRAINT fk_rails_2b94ac124c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2be0318c46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_2be0318c46 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2c5eaaf4e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_locations
    ADD CONSTRAINT fk_rails_2c5eaaf4e6 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_2df2bf3679; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_landmarks
    ADD CONSTRAINT fk_rails_2df2bf3679 FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_2e13879efb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT fk_rails_2e13879efb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_2f03aa5fc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_original_languages
    ADD CONSTRAINT fk_rails_2f03aa5fc9 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_2f4861f981; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_races
    ADD CONSTRAINT fk_rails_2f4861f981 FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- Name: fk_rails_2f8c8cc7c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_creatures
    ADD CONSTRAINT fk_rails_2f8c8cc7c1 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_32c28d0dc2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT fk_rails_32c28d0dc2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_330aabdc9f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planets
    ADD CONSTRAINT fk_rails_330aabdc9f FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_336a88428d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_languages
    ADD CONSTRAINT fk_rails_336a88428d FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_33d25bb9cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_vehicles
    ADD CONSTRAINT fk_rails_33d25bb9cc FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: fk_rails_35622b6831; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_revisions
    ADD CONSTRAINT fk_rails_35622b6831 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: fk_rails_364507f55b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_governments
    ADD CONSTRAINT fk_rails_364507f55b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_364d7e370a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_post_notifications
    ADD CONSTRAINT fk_rails_364d7e370a FOREIGN KEY (post_id) REFERENCES public.thredded_posts(id) ON DELETE CASCADE;


--
-- Name: fk_rails_36d2d6f2ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_creatures
    ADD CONSTRAINT fk_rails_36d2d6f2ea FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_3710eaf0d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_continents
    ADD CONSTRAINT fk_rails_3710eaf0d9 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_3759f5cab1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_floras
    ADD CONSTRAINT fk_rails_3759f5cab1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_37eea989e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_races
    ADD CONSTRAINT fk_rails_37eea989e3 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_38266689fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_floras
    ADD CONSTRAINT fk_rails_38266689fd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3887a53a99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_magics
    ADD CONSTRAINT fk_rails_3887a53a99 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_38af9ca72a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_siblings
    ADD CONSTRAINT fk_rails_38af9ca72a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_38f6d5b974; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_landmarks
    ADD CONSTRAINT fk_rails_38f6d5b974 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_390503c955; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timelines
    ADD CONSTRAINT fk_rails_390503c955 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3a3ae44ed1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_concepts
    ADD CONSTRAINT fk_rails_3a3ae44ed1 FOREIGN KEY (document_analysis_id) REFERENCES public.document_analyses(id);


--
-- Name: fk_rails_3af3827b37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_leaders
    ADD CONSTRAINT fk_rails_3af3827b37 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_3b4205b29f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_creatures
    ADD CONSTRAINT fk_rails_3b4205b29f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3bd0408898; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_landmarks
    ADD CONSTRAINT fk_rails_3bd0408898 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3c1bb51b2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_followings
    ADD CONSTRAINT fk_rails_3c1bb51b2d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3c7bf0f39c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_buildings
    ADD CONSTRAINT fk_rails_3c7bf0f39c FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: fk_rails_3cd83250c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_rails_3cd83250c2 FOREIGN KEY (billing_plan_id) REFERENCES public.billing_plans(id);


--
-- Name: fk_rails_3e58cbbccf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notable_towns
    ADD CONSTRAINT fk_rails_3e58cbbccf FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3e77a3ab03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_parent_technologies
    ADD CONSTRAINT fk_rails_3e77a3ab03 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_3f06f7f0f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_technologies
    ADD CONSTRAINT fk_rails_3f06f7f0f9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_3f582ddff0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_continents
    ADD CONSTRAINT fk_rails_3f582ddff0 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_3fd1f5a94e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_countries
    ADD CONSTRAINT fk_rails_3fd1f5a94e FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_40b95db99c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_landmarks
    ADD CONSTRAINT fk_rails_40b95db99c FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_40bff2caf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_citizens
    ADD CONSTRAINT fk_rails_40bff2caf8 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_423b7b9b62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_groups
    ADD CONSTRAINT fk_rails_423b7b9b62 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_43315fbe2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_religions
    ADD CONSTRAINT fk_rails_43315fbe2e FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_457857aa78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_children
    ADD CONSTRAINT fk_rails_457857aa78 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_46b2407576; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_floras
    ADD CONSTRAINT fk_rails_46b2407576 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_46ef22ab54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_towns
    ADD CONSTRAINT fk_rails_46ef22ab54 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_47834eda23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_creatures
    ADD CONSTRAINT fk_rails_47834eda23 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_49c240fdeb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_countries
    ADD CONSTRAINT fk_rails_49c240fdeb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_4a4c6b868c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_locations
    ADD CONSTRAINT fk_rails_4a4c6b868c FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_4b01e494ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_companions
    ADD CONSTRAINT fk_rails_4b01e494ea FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_4b0a8cfdbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_countries
    ADD CONSTRAINT fk_rails_4b0a8cfdbe FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_4c63abfe98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_countries
    ADD CONSTRAINT fk_rails_4c63abfe98 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_4c65c64f59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_sports
    ADD CONSTRAINT fk_rails_4c65c64f59 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_4cb365bfbc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_sports
    ADD CONSTRAINT fk_rails_4cb365bfbc FOREIGN KEY (sport_id) REFERENCES public.sports(id);


--
-- Name: fk_rails_4cc7a9066b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blockings
    ADD CONSTRAINT fk_rails_4cc7a9066b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_4d19e7db6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_floras
    ADD CONSTRAINT fk_rails_4d19e7db6b FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_4d9e3111de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_towns
    ADD CONSTRAINT fk_rails_4d9e3111de FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_4ea6d3a6e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT fk_rails_4ea6d3a6e7 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_4f9410751c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_traditions
    ADD CONSTRAINT fk_rails_4f9410751c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_504f97e712; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traditions
    ADD CONSTRAINT fk_rails_504f97e712 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_50a1d48d4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_original_languages
    ADD CONSTRAINT fk_rails_50a1d48d4c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_50bc6ca82d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_landmarks
    ADD CONSTRAINT fk_rails_50bc6ca82d FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_50c2667644; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_buildings
    ADD CONSTRAINT fk_rails_50c2667644 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_511056e8f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timelines
    ADD CONSTRAINT fk_rails_511056e8f8 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_512239a8b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_languages
    ADD CONSTRAINT fk_rails_512239a8b1 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_5153e59bb7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_magics
    ADD CONSTRAINT fk_rails_5153e59bb7 FOREIGN KEY (magic_id) REFERENCES public.magics(id);


--
-- Name: fk_rails_52894a2633; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_languages
    ADD CONSTRAINT fk_rails_52894a2633 FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: fk_rails_52d45664c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_jobs
    ADD CONSTRAINT fk_rails_52d45664c9 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_52e90c6e52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_planets
    ADD CONSTRAINT fk_rails_52e90c6e52 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_53223486c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_requests
    ADD CONSTRAINT fk_rails_53223486c1 FOREIGN KEY (application_integration_id) REFERENCES public.application_integrations(id);


--
-- Name: fk_rails_536ae0fffb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_technologies
    ADD CONSTRAINT fk_rails_536ae0fffb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_53b8ddbaec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_religions
    ADD CONSTRAINT fk_rails_53b8ddbaec FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_541e2e5c7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT fk_rails_541e2e5c7b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_560d8dc301; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_groups
    ADD CONSTRAINT fk_rails_560d8dc301 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_5908eec802; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_user_post_notifications
    ADD CONSTRAINT fk_rails_5908eec802 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_595a5e2d38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_groups
    ADD CONSTRAINT fk_rails_595a5e2d38 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_5a26171ce0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_groups
    ADD CONSTRAINT fk_rails_5a26171ce0 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_5ab747cff4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technologies
    ADD CONSTRAINT fk_rails_5ab747cff4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_5b20870439; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religion_deities
    ADD CONSTRAINT fk_rails_5b20870439 FOREIGN KEY (religion_id) REFERENCES public.religions(id);


--
-- Name: fk_rails_5bfc89f70c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_conditions
    ADD CONSTRAINT fk_rails_5bfc89f70c FOREIGN KEY (condition_id) REFERENCES public.conditions(id);


--
-- Name: fk_rails_5c06103aab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_towns
    ADD CONSTRAINT fk_rails_5c06103aab FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_5c58657e1d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_towns
    ADD CONSTRAINT fk_rails_5c58657e1d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_5c6baa3fe2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_characters
    ADD CONSTRAINT fk_rails_5c6baa3fe2 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_5cf276f436; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT fk_rails_5cf276f436 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_5cfcd78702; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_languages
    ADD CONSTRAINT fk_rails_5cfcd78702 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_5d8625161a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traditions
    ADD CONSTRAINT fk_rails_5d8625161a FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_5daaa2f440; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_5daaa2f440 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_5e3d3fd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_foods
    ADD CONSTRAINT fk_rails_5e3d3fd8e4 FOREIGN KEY (food_id) REFERENCES public.foods(id);


--
-- Name: fk_rails_5e9c0a920a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_floras
    ADD CONSTRAINT fk_rails_5e9c0a920a FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_5fa34a7560; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_related_technologies
    ADD CONSTRAINT fk_rails_5fa34a7560 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_5ffd66f029; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_comments
    ADD CONSTRAINT fk_rails_5ffd66f029 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_602827c16a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_characters
    ADD CONSTRAINT fk_rails_602827c16a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_6036d4a67f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_traditions
    ADD CONSTRAINT fk_rails_6036d4a67f FOREIGN KEY (tradition_id) REFERENCES public.traditions(id);


--
-- Name: fk_rails_6050035822; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lores
    ADD CONSTRAINT fk_rails_6050035822 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_61fe1fc3b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_followings
    ADD CONSTRAINT fk_rails_61fe1fc3b1 FOREIGN KEY (content_page_share_id) REFERENCES public.content_page_shares(id);


--
-- Name: fk_rails_625715e589; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_believers
    ADD CONSTRAINT fk_rails_625715e589 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_630b319a8e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_countries
    ADD CONSTRAINT fk_rails_630b319a8e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_63e037973f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_creatures
    ADD CONSTRAINT fk_rails_63e037973f FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_6504914f73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_landmarks
    ADD CONSTRAINT fk_rails_6504914f73 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_657c8efe75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deities
    ADD CONSTRAINT fk_rails_657c8efe75 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_660a8e59b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_floras
    ADD CONSTRAINT fk_rails_660a8e59b7 FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_663908ae63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lores
    ADD CONSTRAINT fk_rails_663908ae63 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_66834cfb3b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_creatures
    ADD CONSTRAINT fk_rails_66834cfb3b FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_66e8529ca6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_leaders
    ADD CONSTRAINT fk_rails_66e8529ca6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_670245ea20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_groups
    ADD CONSTRAINT fk_rails_670245ea20 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_6811950280; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_deities
    ADD CONSTRAINT fk_rails_6811950280 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_68932cea82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_locations
    ADD CONSTRAINT fk_rails_68932cea82 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_6907fc061f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_reports
    ADD CONSTRAINT fk_rails_6907fc061f FOREIGN KEY (content_page_share_id) REFERENCES public.content_page_shares(id);


--
-- Name: fk_rails_695be098be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_floras
    ADD CONSTRAINT fk_rails_695be098be FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_697cd3c08a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_nearby_planets
    ADD CONSTRAINT fk_rails_697cd3c08a FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_6af6f3876f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_children
    ADD CONSTRAINT fk_rails_6af6f3876f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_6b1d33483c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_variations
    ADD CONSTRAINT fk_rails_6b1d33483c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_6b66400484; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_items
    ADD CONSTRAINT fk_rails_6b66400484 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: fk_rails_6bfbd81832; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_capital_towns
    ADD CONSTRAINT fk_rails_6bfbd81832 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_6c51f2aa0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_children
    ADD CONSTRAINT fk_rails_6c51f2aa0b FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_6ca57c7214; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_deities
    ADD CONSTRAINT fk_rails_6ca57c7214 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_6d47dde360; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_creatures
    ADD CONSTRAINT fk_rails_6d47dde360 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7091ae270b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_7091ae270b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_709ec1ec69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_locations
    ADD CONSTRAINT fk_rails_709ec1ec69 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_70d849e91a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_technologies
    ADD CONSTRAINT fk_rails_70d849e91a FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_732b97fd4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_partners
    ADD CONSTRAINT fk_rails_732b97fd4e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7459c5b86c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notice_dismissals
    ADD CONSTRAINT fk_rails_7459c5b86c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_757249240c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_floras
    ADD CONSTRAINT fk_rails_757249240c FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_75adfa0433; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT fk_rails_75adfa0433 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_75f882e414; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_traditions
    ADD CONSTRAINT fk_rails_75f882e414 FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_7682ef94c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_races
    ADD CONSTRAINT fk_rails_7682ef94c3 FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- Name: fk_rails_76a966755f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_groups
    ADD CONSTRAINT fk_rails_76a966755f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_773d2ca583; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_towns
    ADD CONSTRAINT fk_rails_773d2ca583 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_77c46d51a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT fk_rails_77c46d51a4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_785937ca10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_floras
    ADD CONSTRAINT fk_rails_785937ca10 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_79f6a4201f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_relics
    ADD CONSTRAINT fk_rails_79f6a4201f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7a0a570ba1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_7a0a570ba1 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_7a26901707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.towns
    ADD CONSTRAINT fk_rails_7a26901707 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7a8f873624; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_requests
    ADD CONSTRAINT fk_rails_7a8f873624 FOREIGN KEY (integration_authorization_id) REFERENCES public.integration_authorizations(id);


--
-- Name: fk_rails_7aff9f0a17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmarks
    ADD CONSTRAINT fk_rails_7aff9f0a17 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7ba7f2e743; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collections
    ADD CONSTRAINT fk_rails_7ba7f2e743 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_7ca9b9cc86; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_related_landmarks
    ADD CONSTRAINT fk_rails_7ca9b9cc86 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_7cf18fbdfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_languages
    ADD CONSTRAINT fk_rails_7cf18fbdfe FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_7e9edf6226; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_religions
    ADD CONSTRAINT fk_rails_7e9edf6226 FOREIGN KEY (religion_id) REFERENCES public.religions(id);


--
-- Name: fk_rails_7ef5e49d43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_continents
    ADD CONSTRAINT fk_rails_7ef5e49d43 FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_7fdaac3625; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_religions
    ADD CONSTRAINT fk_rails_7fdaac3625 FOREIGN KEY (religion_id) REFERENCES public.religions(id);


--
-- Name: fk_rails_8007529ef0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_towns
    ADD CONSTRAINT fk_rails_8007529ef0 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_81895c349a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_governments
    ADD CONSTRAINT fk_rails_81895c349a FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_83244627a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_locations
    ADD CONSTRAINT fk_rails_83244627a4 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_839218783a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_governments
    ADD CONSTRAINT fk_rails_839218783a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_844c7919c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_landmarks
    ADD CONSTRAINT fk_rails_844c7919c8 FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_849bf97707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_creatures
    ADD CONSTRAINT fk_rails_849bf97707 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_851563604e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_creatures
    ADD CONSTRAINT fk_rails_851563604e FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_85267b3645; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_floras
    ADD CONSTRAINT fk_rails_85267b3645 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8564701168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_rails_8564701168 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_85a57b77d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_nearby_towns
    ADD CONSTRAINT fk_rails_85a57b77d8 FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_85e20de879; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_nearby_landmarks
    ADD CONSTRAINT fk_rails_85e20de879 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_860840595e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_creatures
    ADD CONSTRAINT fk_rails_860840595e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_86bd911a0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_enemies
    ADD CONSTRAINT fk_rails_86bd911a0d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8782b69cf2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_creatures
    ADD CONSTRAINT fk_rails_8782b69cf2 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_87f546669e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_creatures
    ADD CONSTRAINT fk_rails_87f546669e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_88281393d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_countries
    ADD CONSTRAINT fk_rails_88281393d9 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_89a69abd11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_schools
    ADD CONSTRAINT fk_rails_89a69abd11 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: fk_rails_89f34f2745; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents
    ADD CONSTRAINT fk_rails_89f34f2745 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8a5761705f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_magics
    ADD CONSTRAINT fk_rails_8a5761705f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8ac58d75ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_governments
    ADD CONSTRAINT fk_rails_8ac58d75ab FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8b47c0eeda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_floras
    ADD CONSTRAINT fk_rails_8b47c0eeda FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_8b749720ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_languages
    ADD CONSTRAINT fk_rails_8b749720ba FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: fk_rails_8d35c61a0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_magics
    ADD CONSTRAINT fk_rails_8d35c61a0a FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_8f891bd2f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_towns
    ADD CONSTRAINT fk_rails_8f891bd2f0 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_8f8ba7eaa0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_floras
    ADD CONSTRAINT fk_rails_8f8ba7eaa0 FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_9025d4b7d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_authorizations
    ADD CONSTRAINT fk_rails_9025d4b7d9 FOREIGN KEY (application_integration_id) REFERENCES public.application_integrations(id);


--
-- Name: fk_rails_906cddac0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_floras
    ADD CONSTRAINT fk_rails_906cddac0b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_91fec1c73a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_landmarks
    ADD CONSTRAINT fk_rails_91fec1c73a FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_933bdff476; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_rails_933bdff476 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9357a95a09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_citizens
    ADD CONSTRAINT fk_rails_9357a95a09 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_938c9412ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_deities
    ADD CONSTRAINT fk_rails_938c9412ec FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_93d5b570e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_towns
    ADD CONSTRAINT fk_rails_93d5b570e3 FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_93d92763d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_capital_towns
    ADD CONSTRAINT fk_rails_93d92763d1 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_93e2a04270; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_languages
    ADD CONSTRAINT fk_rails_93e2a04270 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9423b9b2dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_floras
    ADD CONSTRAINT fk_rails_9423b9b2dd FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_9459d1f2ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_creatures
    ADD CONSTRAINT fk_rails_9459d1f2ea FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_949bcab7e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_magics
    ADD CONSTRAINT fk_rails_949bcab7e9 FOREIGN KEY (magic_id) REFERENCES public.magics(id);


--
-- Name: fk_rails_94a9348d70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_created_traditions
    ADD CONSTRAINT fk_rails_94a9348d70 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_952c10b554; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planets
    ADD CONSTRAINT fk_rails_952c10b554 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_95a1a881c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floras
    ADD CONSTRAINT fk_rails_95a1a881c7 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_95ae8915de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_governments
    ADD CONSTRAINT fk_rails_95ae8915de FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_9628760141; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_countries
    ADD CONSTRAINT fk_rails_9628760141 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_966803d714; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thredded_messageboard_users
    ADD CONSTRAINT fk_rails_966803d714 FOREIGN KEY (thredded_messageboard_id) REFERENCES public.thredded_messageboards(id) ON DELETE CASCADE;


--
-- Name: fk_rails_966e50d832; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_floras
    ADD CONSTRAINT fk_rails_966e50d832 FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_97c7a64604; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_towns
    ADD CONSTRAINT fk_rails_97c7a64604 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_99c7e69322; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_technologies
    ADD CONSTRAINT fk_rails_99c7e69322 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_9a20edea42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_shares
    ADD CONSTRAINT fk_rails_9a20edea42 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9b677d31b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_deities
    ADD CONSTRAINT fk_rails_9b677d31b3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9bcbf303ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_races
    ADD CONSTRAINT fk_rails_9bcbf303ab FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- Name: fk_rails_9be6ddaa75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_technologies
    ADD CONSTRAINT fk_rails_9be6ddaa75 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_9d18e8d3ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_nearby_planets
    ADD CONSTRAINT fk_rails_9d18e8d3ba FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9d6418053f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_characters
    ADD CONSTRAINT fk_rails_9d6418053f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9ddc7bd04c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_creatures
    ADD CONSTRAINT fk_rails_9ddc7bd04c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_9de694bc46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_languages
    ADD CONSTRAINT fk_rails_9de694bc46 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_9e34682d54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_rails_9e34682d54 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a10ced2eb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_friends
    ADD CONSTRAINT fk_rails_a10ced2eb6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a2488bc582; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_floras
    ADD CONSTRAINT fk_rails_a2488bc582 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_a281e3bbd3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_content_type_activators
    ADD CONSTRAINT fk_rails_a281e3bbd3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a409b836c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_religions
    ADD CONSTRAINT fk_rails_a409b836c0 FOREIGN KEY (religion_id) REFERENCES public.religions(id);


--
-- Name: fk_rails_a4854d982e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_tags
    ADD CONSTRAINT fk_rails_a4854d982e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a4ab309173; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_parents
    ADD CONSTRAINT fk_rails_a4ab309173 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_a4c4a2ac66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_groups
    ADD CONSTRAINT fk_rails_a4c4a2ac66 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_a4d5e4f7c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT fk_rails_a4d5e4f7c9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a555a3bfde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_traditions
    ADD CONSTRAINT fk_rails_a555a3bfde FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a5a64dc4ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_event_entities
    ADD CONSTRAINT fk_rails_a5a64dc4ba FOREIGN KEY (timeline_event_id) REFERENCES public.timeline_events(id);


--
-- Name: fk_rails_a636218385; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT fk_rails_a636218385 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a68c69daea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_jobs
    ADD CONSTRAINT fk_rails_a68c69daea FOREIGN KEY (job_id) REFERENCES public.jobs(id);


--
-- Name: fk_rails_a7695db5e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_analyses
    ADD CONSTRAINT fk_rails_a7695db5e5 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: fk_rails_a782c7d45a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_abilities
    ADD CONSTRAINT fk_rails_a782c7d45a FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_a95fa4c433; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_birthtowns
    ADD CONSTRAINT fk_rails_a95fa4c433 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_a987c38bd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_buildings
    ADD CONSTRAINT fk_rails_a987c38bd5 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_aafdb1fa1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_uploads
    ADD CONSTRAINT fk_rails_aafdb1fa1c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ace0d9d5b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_reports
    ADD CONSTRAINT fk_rails_ace0d9d5b5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ad1f07e86d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_creatures
    ADD CONSTRAINT fk_rails_ad1f07e86d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ae9d7e5838; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_birthtowns
    ADD CONSTRAINT fk_rails_ae9d7e5838 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_af0f6a5143; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_landmarks
    ADD CONSTRAINT fk_rails_af0f6a5143 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_af8fa7ca12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_continents
    ADD CONSTRAINT fk_rails_af8fa7ca12 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b0279f99bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_references
    ADD CONSTRAINT fk_rails_b0279f99bd FOREIGN KEY (attribute_field_id) REFERENCES public.attribute_fields(id);


--
-- Name: fk_rails_b04b89affe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_technologies
    ADD CONSTRAINT fk_rails_b04b89affe FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_b07a172902; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_siblings
    ADD CONSTRAINT fk_rails_b07a172902 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_b0a8cb9c9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_related_lores
    ADD CONSTRAINT fk_rails_b0a8cb9c9e FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_b17ee570a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notable_towns
    ADD CONSTRAINT fk_rails_b17ee570a3 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_b1ac1a4b21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_planets
    ADD CONSTRAINT fk_rails_b1ac1a4b21 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b2daa0ee0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_groups
    ADD CONSTRAINT fk_rails_b2daa0ee0b FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_b4222060dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_countries
    ADD CONSTRAINT fk_rails_b4222060dc FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_b4394c2f72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_schools
    ADD CONSTRAINT fk_rails_b4394c2f72 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_b5860d70f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_religions
    ADD CONSTRAINT fk_rails_b5860d70f0 FOREIGN KEY (religion_id) REFERENCES public.religions(id);


--
-- Name: fk_rails_b59b0cf765; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_followings
    ADD CONSTRAINT fk_rails_b59b0cf765 FOREIGN KEY (page_collection_id) REFERENCES public.page_collections(id);


--
-- Name: fk_rails_b72d29a6a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raffle_entries
    ADD CONSTRAINT fk_rails_b72d29a6a7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b7a61dda35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_largest_towns
    ADD CONSTRAINT fk_rails_b7a61dda35 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fk_rails_b898d20525; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_vehicles
    ADD CONSTRAINT fk_rails_b898d20525 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_b89de05250; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_creatures
    ADD CONSTRAINT fk_rails_b89de05250 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b8f2aeb6b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT fk_rails_b8f2aeb6b9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b958705950; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_planets
    ADD CONSTRAINT fk_rails_b958705950 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_b998e0001f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_pages
    ADD CONSTRAINT fk_rails_b998e0001f FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_b9aaa9f7f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_largest_towns
    ADD CONSTRAINT fk_rails_b9aaa9f7f3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_bb32bf74e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_parents
    ADD CONSTRAINT fk_rails_bb32bf74e8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_bb76d8c681; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_collection_reports
    ADD CONSTRAINT fk_rails_bb76d8c681 FOREIGN KEY (page_collection_id) REFERENCES public.page_collections(id);


--
-- Name: fk_rails_bc0756069b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_landmarks
    ADD CONSTRAINT fk_rails_bc0756069b FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_bc67686fb4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_races
    ADD CONSTRAINT fk_rails_bc67686fb4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_bc92f33499; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_traditions
    ADD CONSTRAINT fk_rails_bc92f33499 FOREIGN KEY (tradition_id) REFERENCES public.traditions(id);


--
-- Name: fk_rails_bd41194a6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT fk_rails_bd41194a6c FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_bfb76d8df6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_parents
    ADD CONSTRAINT fk_rails_bfb76d8df6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_c055deed1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_magics
    ADD CONSTRAINT fk_rails_c055deed1c FOREIGN KEY (magic_id) REFERENCES public.magics(id);


--
-- Name: fk_rails_c1a9aae3dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_religions
    ADD CONSTRAINT fk_rails_c1a9aae3dc FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_c1dafae0c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT fk_rails_c1dafae0c9 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_c1ea207ebf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_sports
    ADD CONSTRAINT fk_rails_c1ea207ebf FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_c31dc3ac40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_floras
    ADD CONSTRAINT fk_rails_c31dc3ac40 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_c36b7cdfc0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_countries
    ADD CONSTRAINT fk_rails_c36b7cdfc0 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: fk_rails_c3c3681b6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_deities
    ADD CONSTRAINT fk_rails_c3c3681b6d FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_c4e908753f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_characters
    ADD CONSTRAINT fk_rails_c4e908753f FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_c5f99896e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_creatures
    ADD CONSTRAINT fk_rails_c5f99896e6 FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_c75da215f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT fk_rails_c75da215f2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_c7bb0c048a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_landmarks
    ADD CONSTRAINT fk_rails_c7bb0c048a FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_c7c0b2560f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_magics
    ADD CONSTRAINT fk_rails_c7c0b2560f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_c7f106d7a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_magics
    ADD CONSTRAINT fk_rails_c7f106d7a8 FOREIGN KEY (magic_id) REFERENCES public.magics(id);


--
-- Name: fk_rails_c8b91c9617; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.religion_deities
    ADD CONSTRAINT fk_rails_c8b91c9617 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_c9b3bef597; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT fk_rails_c9b3bef597 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ca64bef4e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_magics
    ADD CONSTRAINT fk_rails_ca64bef4e0 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_ca943d1cf9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technologies
    ADD CONSTRAINT fk_rails_ca943d1cf9 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_cb114109a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_traditions
    ADD CONSTRAINT fk_rails_cb114109a9 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_cb23113021; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT fk_rails_cb23113021 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_cb260b4429; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_technologies
    ADD CONSTRAINT fk_rails_cb260b4429 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_cbd46d65a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_creatures
    ADD CONSTRAINT fk_rails_cbd46d65a1 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_cbd8ef1f3d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT fk_rails_cbd8ef1f3d FOREIGN KEY (document_analysis_id) REFERENCES public.document_analyses(id);


--
-- Name: fk_rails_cc7262669e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_countries
    ADD CONSTRAINT fk_rails_cc7262669e FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_cd5ecbca0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_towns
    ADD CONSTRAINT fk_rails_cd5ecbca0b FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_cd7b28ee91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_character_partners
    ADD CONSTRAINT fk_rails_cd7b28ee91 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_ce6a782d57; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_creatures
    ADD CONSTRAINT fk_rails_ce6a782d57 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_cef03de1b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_change_events
    ADD CONSTRAINT fk_rails_cef03de1b7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d09301a717; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_partners
    ADD CONSTRAINT fk_rails_d09301a717 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_d0fb1daa7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_foods
    ADD CONSTRAINT fk_rails_d0fb1daa7b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d101f01cc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_groups
    ADD CONSTRAINT fk_rails_d101f01cc6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d33a59a20f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_partners
    ADD CONSTRAINT fk_rails_d33a59a20f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d34937a68f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_floras
    ADD CONSTRAINT fk_rails_d34937a68f FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_d3b6775521; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_planets
    ADD CONSTRAINT fk_rails_d3b6775521 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d43dae98c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_authorizations
    ADD CONSTRAINT fk_rails_d43dae98c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d51272a189; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT fk_rails_d51272a189 FOREIGN KEY (votable_id) REFERENCES public.votables(id);


--
-- Name: fk_rails_d6def629e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_countries
    ADD CONSTRAINT fk_rails_d6def629e5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d6f3e1e9db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_jobs
    ADD CONSTRAINT fk_rails_d6f3e1e9db FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d71699382b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_child_technologies
    ADD CONSTRAINT fk_rails_d71699382b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_d799c80ed2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_countries
    ADD CONSTRAINT fk_rails_d799c80ed2 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_d84e0583a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_characters
    ADD CONSTRAINT fk_rails_d84e0583a4 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_d8b5e1d4fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_countries
    ADD CONSTRAINT fk_rails_d8b5e1d4fb FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_d8c9ed5bfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_variations
    ADD CONSTRAINT fk_rails_d8c9ed5bfe FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_d916e70471; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_planets
    ADD CONSTRAINT fk_rails_d916e70471 FOREIGN KEY (planet_id) REFERENCES public.planets(id);


--
-- Name: fk_rails_d926f2d333; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_governments
    ADD CONSTRAINT fk_rails_d926f2d333 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_d9b11f633b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_towns
    ADD CONSTRAINT fk_rails_d9b11f633b FOREIGN KEY (town_id) REFERENCES public.towns(id);


--
-- Name: fk_rails_d9e4614728; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_landmarks
    ADD CONSTRAINT fk_rails_d9e4614728 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_dba457a3e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_creatures
    ADD CONSTRAINT fk_rails_dba457a3e9 FOREIGN KEY (technology_id) REFERENCES public.technologies(id);


--
-- Name: fk_rails_dd9c945bde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_countries
    ADD CONSTRAINT fk_rails_dd9c945bde FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_de3379066f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_items
    ADD CONSTRAINT fk_rails_de3379066f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_de8ed2bf0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_locations
    ADD CONSTRAINT fk_rails_de8ed2bf0d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_deab325ea6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deities
    ADD CONSTRAINT fk_rails_deab325ea6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_df6238c8a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_df6238c8a6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_dfd8a3e817; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_religions
    ADD CONSTRAINT fk_rails_dfd8a3e817 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e02e24e2c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_conditions
    ADD CONSTRAINT fk_rails_e02e24e2c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e0f705d79d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_related_lores
    ADD CONSTRAINT fk_rails_e0f705d79d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e14182d024; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_pages
    ADD CONSTRAINT fk_rails_e14182d024 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e164ac0d81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_continents
    ADD CONSTRAINT fk_rails_e164ac0d81 FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_e225c55725; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_creatures
    ADD CONSTRAINT fk_rails_e225c55725 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_e271d0e90b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_groups
    ADD CONSTRAINT fk_rails_e271d0e90b FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: fk_rails_e295facadd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_towns
    ADD CONSTRAINT fk_rails_e295facadd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e2cf738d18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_magics
    ADD CONSTRAINT fk_rails_e2cf738d18 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e4326387a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_races
    ADD CONSTRAINT fk_rails_e4326387a1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e765ded7c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_parents
    ADD CONSTRAINT fk_rails_e765ded7c0 FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_e7783bd156; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_floras
    ADD CONSTRAINT fk_rails_e7783bd156 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e806d89196; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_nearby_towns
    ADD CONSTRAINT fk_rails_e806d89196 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e8a5d9aed7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_languages
    ADD CONSTRAINT fk_rails_e8a5d9aed7 FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: fk_rails_e8c8480156; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT fk_rails_e8c8480156 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_e8eab5c9a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paypal_invoices
    ADD CONSTRAINT fk_rails_e8eab5c9a7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_e94d4cf5ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_page_share_followings
    ADD CONSTRAINT fk_rails_e94d4cf5ae FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_eb35caf879; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.town_nearby_landmarks
    ADD CONSTRAINT fk_rails_eb35caf879 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_eba19193fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_entities
    ADD CONSTRAINT fk_rails_eba19193fd FOREIGN KEY (document_analysis_id) REFERENCES public.document_analyses(id);


--
-- Name: fk_rails_ec5ea364f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_creatures
    ADD CONSTRAINT fk_rails_ec5ea364f7 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_ed26e147fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_languages
    ADD CONSTRAINT fk_rails_ed26e147fc FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: fk_rails_ed30ed1f56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_creatures
    ADD CONSTRAINT fk_rails_ed30ed1f56 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_eedfb1da43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_floras
    ADD CONSTRAINT fk_rails_eedfb1da43 FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_ef89149eed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deity_deity_siblings
    ADD CONSTRAINT fk_rails_ef89149eed FOREIGN KEY (deity_id) REFERENCES public.deities(id);


--
-- Name: fk_rails_ef9b8612fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_religions
    ADD CONSTRAINT fk_rails_ef9b8612fb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f0782030ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_popular_foods
    ADD CONSTRAINT fk_rails_f0782030ed FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_f09fffaa4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_popular_foods
    ADD CONSTRAINT fk_rails_f09fffaa4d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f1a58151e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floras
    ADD CONSTRAINT fk_rails_f1a58151e3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f2550b14aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent_governments
    ADD CONSTRAINT fk_rails_f2550b14aa FOREIGN KEY (continent_id) REFERENCES public.continents(id);


--
-- Name: fk_rails_f280932d6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_companions
    ADD CONSTRAINT fk_rails_f280932d6e FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_f32e341576; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_floras
    ADD CONSTRAINT fk_rails_f32e341576 FOREIGN KEY (flora_id) REFERENCES public.floras(id);


--
-- Name: fk_rails_f35621c25d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_deities
    ADD CONSTRAINT fk_rails_f35621c25d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f3845e4b82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_vehicles
    ADD CONSTRAINT fk_rails_f3845e4b82 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f3bed37b21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_items
    ADD CONSTRAINT fk_rails_f3bed37b21 FOREIGN KEY (government_id) REFERENCES public.governments(id);


--
-- Name: fk_rails_f3fbfead99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_countries
    ADD CONSTRAINT fk_rails_f3fbfead99 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_f4280f419b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.towns
    ADD CONSTRAINT fk_rails_f4280f419b FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_f561aabd30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_creatures
    ADD CONSTRAINT fk_rails_f561aabd30 FOREIGN KEY (creature_id) REFERENCES public.creatures(id);


--
-- Name: fk_rails_f580cb070a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_bordering_countries
    ADD CONSTRAINT fk_rails_f580cb070a FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fk_rails_f7f2869fc2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_created_traditions
    ADD CONSTRAINT fk_rails_f7f2869fc2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_f8eedaa100; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_love_interests
    ADD CONSTRAINT fk_rails_f8eedaa100 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: fk_rails_fb4ef20dba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.landmark_creatures
    ADD CONSTRAINT fk_rails_fb4ef20dba FOREIGN KEY (landmark_id) REFERENCES public.landmarks(id);


--
-- Name: fk_rails_fbee4b6849; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_foods
    ADD CONSTRAINT fk_rails_fbee4b6849 FOREIGN KEY (lore_id) REFERENCES public.lores(id);


--
-- Name: fk_rails_fc380e6891; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lore_continents
    ADD CONSTRAINT fk_rails_fc380e6891 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_fd542e857a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.government_political_figures
    ADD CONSTRAINT fk_rails_fd542e857a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_fefb4182fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technology_related_technologies
    ADD CONSTRAINT fk_rails_fefb4182fe FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_fefd082dbd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents
    ADD CONSTRAINT fk_rails_fefd082dbd FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: fk_rails_ff041e28f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_religions
    ADD CONSTRAINT fk_rails_ff041e28f9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ff29554037; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_love_interests
    ADD CONSTRAINT fk_rails_ff29554037 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_ffe3de2639; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT fk_rails_ffe3de2639 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: fk_rails_fffaee91fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT fk_rails_fffaee91fa FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

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
('20210524231019'),
('20210524232455');


