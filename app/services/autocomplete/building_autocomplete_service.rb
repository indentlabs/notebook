module Autocomplete
  class BuildingAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type_of', 'type', 'building_type', 'building type', 'type of building'
        t('building_types')
      when 'architectural style', 'architecture'
        t('architectural_styles')
      else
        []
      end.uniq
    end
  end
end