# TODO: We should probably migrate towards using string names instead of actual class references (like we
# do below) so we can make sure they're always available (e.g. metaprogramming on class definitions).
# Otherwise, we're loading these classes into memory before this initializer (and/or other initializers)
# have run. See HasPageReferences for an example of why we needed content_type_names instead of content_types.
Rails.application.config.content_type_names = {
  all: %w(
    Universe Character Location Item Building Condition Continent Country Creature Deity Flora
    Food Government Group Job Landmark Language Lore Magic Planet Race Religion Scene
    School Sport Technology Timeline Town Tradition Vehicle
  )
}

# We wrap this in a block so we can call it once on boot, and again on every reload.
# This ensures that we don't hold onto stale references to classes (e.g. Universe)
# after a reload, which causes "A copy of ... has been removed from the module tree but is still active!" errors.
configure_content_types = -> do
  Rails.application.config.content_types = {
    # The complete list of all content types, dictates ordering in sidebar
    all: [
      Universe, Character, Location, Item, Building, Condition, Continent, Country, Creature, Deity, Flora,
      Food, Government, Group, Job, Landmark, Language, Lore, Magic, Planet, Race, Religion, Scene,
      School, Sport, Technology, Timeline, Town, Tradition, Vehicle,
    ],

    # These content types are always on for all users, and cannot be toggled off
    always_on: [Universe],

    # These content types are turned on by default for new users, but can be toggled off
    default_on: [Character, Location, Item],

    # These content types are available to be turned on
    available: [
      Building, Condition, Country, Creature, Deity, Flora, Government, Group, Job, Landmark, Language,
      Magic, Planet, Race, Religion, Scene, Technology, Timeline, Town, Tradition, Vehicle, Sport, School, Food,
      Continent, Lore
    ],

    # These content types can be created by any user
    free: [Universe, Character, Location, Item],

    # These content types require a premium subscription to create
    premium: [
      Creature, 
      Flora, 
      Planet, 
      Continent,
      Country, 
      Landmark,
      Town, 
      Building,
      School,
      Job,
      Technology,
      Timeline,
      Lore,
      Vehicle,
      Condition, 
      Race, 
      Deity, 
      Religion, 
      Magic, 
      Government, 
      Group, 
      Language,
      Tradition,
      Food, 
      Sport, 
      Scene, 
    ],

    # Content types to label as "new" around the site
    new: [

    ]
  }

  Rails.application.config.content_types[:all_non_universe] = Rails.application.config.content_types[:all] - [Universe]

  Rails.application.config.content_types_by_name = Rails.application.config.content_types[:all].map { |type| [type.name, type] }.to_h
  Rails.application.config.content_types_by_name['Document'] = Document
  Rails.application.config.content_types_by_name['Timeline'] = Timeline
end

# Run once on boot
configure_content_types.call

# Run on every reload
Rails.application.reloader.to_prepare do
  configure_content_types.call
end