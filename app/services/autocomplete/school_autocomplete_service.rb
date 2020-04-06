module Autocomplete
  class SchoolAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type_of', 'type', 'type of school'
        t('school_types')
      else
        []
      end.uniq
    end
  end
end