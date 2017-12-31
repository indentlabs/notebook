require 'active_support/concern'

module HasContent
  extend ActiveSupport::Concern

  included do
    # Base content types
    has_many :universes
    has_many :characters
    has_many :items
    has_many :locations

    # Extended content types
    has_many :creatures
    has_many :races
    has_many :religions
    has_many :magics
    has_many :languages
    has_many :groups
    has_many :floras
    has_many :towns
    has_many :countries
    has_many :landmarks

    # Collective content types
    has_many :scenes

    has_many :attribute_fields
    has_many :attribute_categories
    has_many :attribute_values, class_name: 'Attribute'

    def content
      {
        characters: characters,
        items: items,
        locations: locations,
        universes: universes,
        creatures: creatures,
        races: races,
        religions: religions,
        magics: magics,
        languages: languages,
        scenes: scenes,
        groups: groups,
        towns: towns,
        countries: countries,
        landmarks: landmarks
      }
    end

    def content_list
      [
        universes,
        characters,
        items,
        locations,
        creatures,
        races,
        religions,
        magics,
        languages,
        scenes,
        groups,
        towns,
        countries,
        landmarks
      ].flatten
    end

    def content_in_universe universe_id
      {
        characters: characters.in_universe(universe_id),
        items:      items.in_universe(universe_id),
        locations:  locations.in_universe(universe_id),
        creatures:  creatures.in_universe(universe_id),
        races:      races.in_universe(universe_id),
        religions:  religions.in_universe(universe_id),
        magics:     magics.in_universe(universe_id),
        languages:  languages.in_universe(universe_id),
        scenes:     scenes.in_universe(universe_id),
        groups:     groups.in_universe(universe_id),
        towns:      towns.in_universe(universe_id),
        landmarks:  landmarks.in_universe(universe_id),
        countries:  countries.in_universe(universe_id)
      }
    end

    def content_count
      [
        characters.length,
        items.length,
        locations.length,
        universes.length,
        creatures.length,
        races.length,
        religions.length,
        magics.length,
        languages.length,
        scenes.length,
        groups.length,
        towns.length,
        landmarks.length,
        countries.length
      ].sum
    end

    def public_content
      {
        characters: characters.is_public,
        items: items.is_public,
        locations: locations.is_public,
        universes: universes.is_public,
        creatures: creatures.is_public,
        races: races.is_public,
        religions: religions.is_public,
        magics: magics.is_public,
        languages: languages.is_public,
        scenes: scenes.is_public,
        groups: groups.is_public,
        towns: towns.is_public,
        countries: countries.is_public,
        landmarks: landmarks.is_public
      }
    end

    def public_content_count
      [
        characters.is_public.length,
        items.is_public.length,
        locations.is_public.length,
        universes.is_public.length,
        creatures.is_public.length,
        races.is_public.length,
        religions.is_public.length,
        magics.is_public.length,
        languages.is_public.length,
        scenes.is_public.length,
        groups.is_public.length,
        towns.is_public.length,
        countries.is_public.length,
        landmarks.is_public.length
      ].sum
    end

    def recent_content
      [
        characters, locations, items, universes,
        creatures, races, religions, magics, languages,
        scenes, groups, towns, countries, landmarks
      ].flatten
      .sort_by(&:updated_at)
      .last(3)
      .reverse
    end
  end
end
