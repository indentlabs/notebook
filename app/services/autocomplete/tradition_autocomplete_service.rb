module Autocomplete
  class TraditionAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type of tradition'
        t('tradition_types')
      else
        []
      end.uniq
    end
  end
end