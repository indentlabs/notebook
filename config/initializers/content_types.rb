Rails.application.config.content_types = {
  # The complete list of all content types
  all: [
    Universe, Character, Location, Item, Country, Creature, Deity, Flora,
    Government, Group, Landmark, Language, Magic, Planet, Race, Religion, Scene,
    Technology, Town
  ],

  # These content types are always on for all users, and cannot be toggled off
  always_on: [Universe],

  # These content types are turned on by default for new users, but can be toggled off
  default_on: [Character, Location, Item],

  # These content types are available to be turned on
  available: [
    Country, Creature, Deity, Flora, Government, Group, Landmark, Language,
    Magic, Planet, Race, Religion, Scene, Technology, Town
  ],

  # These content types can be created by any user
  free: [Universe, Character, Location, Item],

  # These content types require a premium subscription to create
  premium: [
    Country, Creature, Deity, Flora, Government, Group, Landmark, Language,
    Magic, Planet, Race, Religion, Scene, Technology, Town
  ]
}

Rails.application.config.content_types[:all_non_universe] = Rails.application.config.content_types[:all] - [Universe]
