module Autocomplete
  class ConditionAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type_of_condition', 'type of condition'
        t('condition_types')
      else
        []
      end.uniq
    end
  end
end