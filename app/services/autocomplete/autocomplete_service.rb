class AutocompleteService < Service
  def self.for_field_label(label:, content_model: nil)
    case content_model.name
    when Universe.name
      Autocomplete::UniverseAutocompleteService.for_field_label(label)
    when Character.name
      Autocomplete::CharacterAutocompleteService.for_field_label(label)
    when Location.name
      Autocomplete::LocationAutocompleteService.for_field_label(label)
    when Item.name
      Autocomplete::ItemAutocompleteService.for_field_label(label)
    when Building.name
      Autocomplete::BuildingAutocompleteService.for_field_label(label)
    when Lore.name
      Autocomplete::LoreAutocompleteService.for_field_label(label)
    when Condition.name
      Autocomplete::ConditionAutocompleteService.for_field_label(label)
    when Creature.name
      Autocomplete::CreatureAutocompleteService.for_field_label(label)
    when Food.name
      Autocomplete::FoodAutocompleteService.for_field_label(label)
    when Job.name
      Autocomplete::JobAutocompleteService.for_field_label(label)
    when Landmark.name
      Autocomplete::LandmarkAutocompleteService.for_field_label(label)
    when Magic.name
      Autocomplete::MagicAutocompleteService.for_field_label(label)
    when School.name
      Autocomplete::SchoolAutocompleteService.for_field_label(label)
    else
      []
    end
  end

  def self.autocompleteable?(field_label:, content_model: nil)
    self.for_field_label(label: field_label, content_model: content_model).any?
  end

  # helper method for derivative classes so we don't have to I18n every time
  def self.t(key)
    I18n.t(key, scope: 'autocomplete')
  end
end
