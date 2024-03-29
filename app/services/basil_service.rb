class BasilService < Service
  FREE_IMAGE_LIMIT   = 100
  MAX_JOB_QUEUE_SIZE = 3

  IGNORED_VALUES = ['', 'none', 'n/a', '.', '-', ' ', '?', '??', '???', 'x', nil]

  ENABLED_PAGE_TYPES = [
    Character, Location, Item,
    Creature, Flora,
    Food, Planet, 
    Landmark, Town,

    # TODO improve these before release, if possible; otherwise disable
    # Building, Vehicle, 

    # TODO before release
    # Continent, Country,
    # Creature, Deity,
    # Magic, School, Sport, Technology,
    # Tradition

    # Probably won't do before release
    # Condition, Government, Group, Job, Language, Lore,
    # Race, Religion, Scene
  ].map(&:name)

  def self.enabled_styles_for(page_type)
    case page_type
    when 'Character'
      %w(realistic painting sketch digital abstract watercolor)
    when 'Location'
      %w(realistic painting sketch)
    when 'Item'
      %w(realistic painting sketch)
    when 'Building'
      %w(realistic sketch)
    when 'Town'
      %w(realistic map)
    when 'Creature'
      %w(realistic fantasy)
    else
      %w(realistic)
    end
  end

  def self.experimental_styles_for(page_type)
    case page_type
    when 'Character'
      %w(realistic2 realistic3 painting2 painting3 horror anime)
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