class AutocompleteService < Service
  # TODO not make this so awful

  # Adding a field name to this switch/case will enable autocompleting
  # for that field across any page type.
  def self.for(field_name)
    case field_name
    when 'bodytype'
      t('body_types')
    when 'eyecolor'
      t('eye_colors')
    when 'facialhair'
      t('facial_hair_styles')
    when 'fave_weapon'
      t('weapon_types') + t('shield_types') + t('axe_types') + t('bow_types') +
      t('club_types') + t('flexible_weapon_types') + t('fist_weapon_types') + t('thrown_weapon_types') +
      t('polearm_types') + t('shortsword_types') + t('sword_types')
    when 'hairstyle'
      t('hair_styles')
    when 'haircolor'
      t('hair_colors')
    when 'item_type'
      t('weapon_types') + t('shield_types') + t('axe_types') + t('bow_types') +
      t('club_types') + t('flexible_weapon_types') + t('fist_weapon_types') + t('thrown_weapon_types') +
      t('polearm_types') + t('shortsword_types') + t('sword_types') + t('other_item_types')
    when 'race'
      t('character_races')
    when 'skintone'
      t('skin_tones')
    else
      []
    end
  end

  def self.autocompleteable?(field_name)
    self.for(field_name).any?
  end

  def self.t(key)
    I18n.t(key)
  end
end
