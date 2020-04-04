module Autocomplete
  class LocationAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type_of', 'type'
        t('location_types')
      else
        []
      end.uniq
    end
  end
end