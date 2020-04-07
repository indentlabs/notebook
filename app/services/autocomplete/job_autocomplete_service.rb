module Autocomplete
  class JobAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type', 'type of job'
        t('job_types')
      else
        []
      end.uniq
    end
  end
end