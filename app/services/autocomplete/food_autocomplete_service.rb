module Autocomplete
  class FoodAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type of food'
        t('food_types')
      else
        []
      end.uniq
    end
  end
end