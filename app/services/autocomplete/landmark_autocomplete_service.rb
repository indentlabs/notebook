module Autocomplete
  class LandmarkAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'category', 'type of landmark'
        t('landmark_types')
      else
        []
      end.uniq
    end
  end
end