class AutocompleteService < Service
  def self.for_field_label(label:, content_model: nil)
    case content_model.name
    when Universe.name
      Autocomplete::UniverseAutocompleteService.for_field_label(label)
    when Character.name
      Autocomplete::CharacterAutocompleteService.for_field_label(label)
    when Location.name
      Autocomplete::LocationAutocompleteService.for_field_label(label)
    when Lore.name
      Autocomplete::LoreAutocompleteService.for_field_label(label)
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
