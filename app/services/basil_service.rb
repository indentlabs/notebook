class BasilService < Service
  FREE_IMAGE_LIMIT   = 100
  MAX_JOB_QUEUE_SIZE = 3

  IGNORED_VALUES = ['', 'none', 'n/a', '.', '-', ' ', '?', '??', '???', 'x', nil]

  ENABLED_PAGE_TYPES = [
    Character, Location, Item,
    Creature, Flora,
    Food, Planet, 
    Landmark, Town,

    # In the next release
    Building,
    Vehicle, 
    Deity,
    Technology,
    Tradition,

    # TODO before release
    # Continent, Country,
    # Magic, School, Sport,

    # Probably won't do before release
    # Condition, Government, Group, Job, Language, Lore,
    # Race, Religion, Scene
  ].map(&:name).sort_by(&:downcase)

  def self.enabled_styles_for(page_type)
    case page_type
    when 'Character'
      %w(photograph watercolor_painting pencil_sketch smiling villain horror)
    when 'Location'
      %w(painting watercolor_painting sketch)
    when 'Item'
      %w(photograph watercolor_painting pencil_sketch)
    when 'Landmark'
      %w(photograph watercolor_painting)
    when 'Flora'
      %w(photograph watercolor_painting)
    when 'Building'
      %w(photograph interior exterior aerial_photograph)
    when 'Town'
      %w(photograph)
    when 'Creature'
      %w(amateur_photograph fantasy)
    when 'Technology'
      %w(product_photography macro_photography cutaway_render)
    when 'Vehicle'
      %w(photograph watercolor_painting anime)
    when 'Tradition'
      %w(action_shot watercolor_painting)
    when 'Deity'
      %w(photograph watercolor_painting anime)
    else
      %w(photograph)
    end
  end

  def self.experimental_styles_for(page_type)
    case page_type
    when 'Character'
      %w(anime fantasy scifi historical abstract caricature)
    when 'Location'
      %w(aerial_photograph anime)
    when 'Item'
      %w(schematic anime hand_made)
    when 'Flora'
      %w(bouquet)
    when 'Deity'
      %w(celestial_body abstract geometric symbolic)
    when 'Building'
      %w(dystopian utopian pencil_sketch)
    when 'Vehicle'
      %w(futuristic vintage schematic steampunk)
    when 'Deity'
      %w()
    when 'Technology'
      %w(concept_art early_prototype ancient_technology steampunk)
    when 'Landmark'
      %w(map_icon)
    when 'Tradition'
      %w(anime cinematic_shot amateur_photography)
    when 'Town'
      %w(map)
    else
      []
    end
  end

  def self.include_all_fields_in_category(user, page, category_label)
    category = AttributeCategory.where(
      user_id:     user.id,
      entity_type: page.page_type.downcase,
      label:       category_label
    )
    return nil if category.empty?

    fields = AttributeField.where(
      attribute_category_id: category.pluck(:id),
      field_type:            ['name', 'text_area', 'textarea'],
      hidden:                [nil, false]
    )
    return nil if fields.empty?

    answers = Attribute.where(
      attribute_field_id: fields.pluck(:id),
      entity_id:          page.id,
      entity_type:        page.page_type,
    ).where.not(value: IGNORED_VALUES)
    return nil if answers.empty?

    # If we have some fields AND we have some answers, go ahead and zip them up
    # into an array of [field, answer] pairs to return.
    answers.map do |answer|
      field = fields.find { |f| f.id == answer.attribute_field_id }
      [field, answer.value]
    end
  end

  def self.include_specific_field(user, page, category_label, field_label)
    category = AttributeCategory.find_by(
      user_id:     user.id,
      entity_type: page.page_type.downcase,
      label:       category_label
    )
    return nil if category.nil?

    field = AttributeField.find_by(
      attribute_category_id: category.id,
      label:                 field_label,
      hidden:                [nil, false]
    )
    return nil if field.nil?

    value = Attribute.where(attribute_field_id: field.id,
                            entity_type:        page.page_type,
                            entity_id:          page.id)
                     .where.not(value: IGNORED_VALUES)
                     .first
    return nil if value.nil? || value.try(:value).blank?

    # If we get through it all and ACTUALLY have a value, return it
    # in the form of [field, value].
    return [field, value.value]
  end
end