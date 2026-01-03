# TODO: We should probably migrate towards using string names instead of actual class references (like we
# do below) so we can make sure they're always available (e.g. metaprogramming on class definitions).
# Otherwise, we're loading these classes into memory before this initializer (and/or other initializers)
# have run. See HasPageReferences for an example of why we needed content_type_names instead of content_types.
Rails.application.config.content_type_names = {
  all: %w(
    Universe Character Location Item Building Condition Continent Country Creature Deity Flora
    Food Government Group Job Landmark Language Lore Magic Planet Race Religion Scene
    School Sport Technology Timeline Town Tradition Vehicle Book
  )
}

# We wrap this in a block so we can call it once on boot, and again on every reload.
# This ensures that we don't hold onto stale references to classes (e.g. Universe)
# after a reload, which causes "A copy of ... has been removed from the module tree but is still active!" errors.
# We wrap this in a block so we can call it once on boot, and again on every reload.
# This ensures that we don't hold onto stale references to classes (e.g. Universe)
# after a reload, which causes "A copy of ... has been removed from the module tree but is still active!" errors.
configure_content_types = -> do
  Rails.application.config.content_types = {
    # The complete list of all content types, dictates ordering in sidebar
    all: [
      'Universe'.constantize, 'Character'.constantize, 'Location'.constantize, 'Item'.constantize, 'Building'.constantize, 'Condition'.constantize, 'Continent'.constantize, 'Country'.constantize, 'Creature'.constantize, 'Deity'.constantize, 'Flora'.constantize,
      'Food'.constantize, 'Government'.constantize, 'Group'.constantize, 'Job'.constantize, 'Landmark'.constantize, 'Language'.constantize, 'Lore'.constantize, 'Magic'.constantize, 'Planet'.constantize, 'Race'.constantize, 'Religion'.constantize, 'Scene'.constantize,
      'School'.constantize, 'Sport'.constantize, 'Technology'.constantize, 'Timeline'.constantize, 'Town'.constantize, 'Tradition'.constantize, 'Vehicle'.constantize,
    ],

    # These content types are always on for all users, and cannot be toggled off
    always_on: ['Universe'.constantize],

    # These content types are turned on by default for new users, but can be toggled off
    default_on: ['Character'.constantize, 'Location'.constantize, 'Item'.constantize],

    # These content types are available to be turned on
    available: [
      'Building'.constantize, 'Condition'.constantize, 'Country'.constantize, 'Creature'.constantize, 'Deity'.constantize, 'Flora'.constantize, 'Government'.constantize, 'Group'.constantize, 'Job'.constantize, 'Landmark'.constantize, 'Language'.constantize,
      'Magic'.constantize, 'Planet'.constantize, 'Race'.constantize, 'Religion'.constantize, 'Scene'.constantize, 'Technology'.constantize, 'Timeline'.constantize, 'Town'.constantize, 'Tradition'.constantize, 'Vehicle'.constantize, 'Sport'.constantize, 'School'.constantize, 'Food'.constantize,
      'Continent'.constantize, 'Lore'.constantize
    ],

    # These content types can be created by any user
    free: ['Universe'.constantize, 'Character'.constantize, 'Location'.constantize, 'Item'.constantize],

    # These content types require a premium subscription to create
    premium: [
      'Creature'.constantize, 
      'Flora'.constantize, 
      'Planet'.constantize, 
      'Continent'.constantize,
      'Country'.constantize, 
      'Landmark'.constantize,
      'Town'.constantize, 
      'Building'.constantize,
      'School'.constantize,
      'Job'.constantize,
      'Technology'.constantize,
      'Timeline'.constantize,
      'Lore'.constantize,
      'Vehicle'.constantize,
      'Condition'.constantize, 
      'Race'.constantize, 
      'Deity'.constantize, 
      'Religion'.constantize, 
      'Magic'.constantize, 
      'Government'.constantize, 
      'Group'.constantize, 
      'Language'.constantize,
      'Tradition'.constantize,
      'Food'.constantize, 
      'Sport'.constantize, 
      'Scene'.constantize, 
    ],

    # Content types to label as "new" around the site
    new: [

    ]
  }

  Rails.application.config.content_types[:all_non_universe] = Rails.application.config.content_types[:all] - ['Universe'.constantize]

  Rails.application.config.content_types_by_name = Rails.application.config.content_types[:all].map { |type| [type.name, type] }.to_h
  Rails.application.config.content_types_by_name['Document'] = 'Document'.constantize
  Rails.application.config.content_types_by_name['Timeline'] = 'Timeline'.constantize
  Rails.application.config.content_types_by_name['Book'] = 'Book'.constantize
end

# Run once on boot
configure_content_types.call

# Run on every reload
Rails.application.reloader.to_prepare do
  configure_content_types.call
end