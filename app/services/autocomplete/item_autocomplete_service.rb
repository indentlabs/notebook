module Autocomplete
  class ItemAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'type_of', 'type', 'item_type', 'item type'
        [
          t('axe_types'), t('bow_types'), t('club_types'), t('fist_weapon_types'),
          t('flexible_weapon_types'), t('other_item_types'), t('polearm_types'), 
          t('shield_types'), t('shortsword_types'), t('sword_types'),
          t('thrown_weapon_types'), t('weapon_types'), 
        ].sum

      else
        []
      end.uniq
    end
  end
end