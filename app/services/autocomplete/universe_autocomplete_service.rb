module Autocomplete
  class UniverseAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'genre'
        t('genres')
      else
        []
      end.uniq
    end
  end
end