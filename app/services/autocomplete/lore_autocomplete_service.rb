module Autocomplete
  class LoreAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type'
        t('lore_types')
      when 'genre'
        t('genres')
      else
        []
      end.uniq
    end
  end
end