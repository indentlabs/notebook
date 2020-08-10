module Autocomplete
  class VehicleAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type of vehicle'
        t('vehicle_types')
      else
        []
      end.uniq
    end
  end
end