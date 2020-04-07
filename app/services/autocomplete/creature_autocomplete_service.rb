module Autocomplete
  class CreatureAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type of creature'
        t('creature_types')
      else
        []
      end.uniq
    end
  end
end