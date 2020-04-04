module Autocomplete
  class CharacterAutocompleteService < AutocompleteService
    def self.for_field_label(field_label)
      case field_label.downcase
      when 'archetype', 'role'
        t('archetypes')
      when 'eye color', 'eyecolor', 'eyecolour', 'eye colour'
        t('eye_colors')
      when 'bodytype', 'body type'
        t('body_types')
      when 'facialhair', 'facial hair'
        t('facial_hair_styles')
      when 'fave weapon', 'weapon', 'favorite weapon', 'favourite weapon'
        t('weapon_types')  + t('shield_types')          + t('axe_types')         + t('bow_types') +
        t('club_types')    + t('flexible_weapon_types') + t('fist_weapon_types') + t('thrown_weapon_types') +
        t('polearm_types') + t('shortsword_types')      + t('sword_types')
      when 'hairstyle', 'hair style'
        t('hair_styles')
      when 'haircolor', 'hair color', 'haircolour', 'hair colour'
        t('hair_colors')
      when 'race'
        t('character_races')
      when 'skintone', 'skin tone', 'skin'
        t('skin_tones')
      else
        []
      end.uniq
    end
  end
end