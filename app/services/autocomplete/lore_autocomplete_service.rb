module Autocomplete
  class LoreAutocompleteService < Service
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type'
        t('lore_types')
      when 'genre'
        t('genres')
      else
        []
      end.uniq
    end

    def self.autocompleteable?(field_label:, content_model: nil)
      self.for_field_label(field_label).any?
    end

    # helper method so we don't have to I18n every time
    def self.t(key)
      I18n.t(key, scope: 'autocomplete')
    end
  end
end