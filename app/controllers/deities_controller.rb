
class DeitiesController < ContentController
  private

  def content_param_list
    [
      :name, :description, :other_names, :physical_description, :height,
      :weight, :symbols, :elements, :strengths, :weaknesses, :prayers, :rituals,
      :human_interaction, :notable_events, :family_history, :life_story, :notes,
      :private_notes, :privacy, :universe_id
    ] + [
      deity_character_parents_attributes: [:id, :character_parent_id, :_destroy],
      deity_character_partners_attributes: [:id, :character_partner_id, :_destroy],
      deity_character_children_attributes: [:id, :character_child_id, :_destroy],
      deity_deity_parents_attributes: [:id, :deity_parent_id, :_destroy],
      deity_deity_partners_attributes: [:id, :deity_partner_id, :_destroy],
      deity_deity_children_attributes: [:id, :deity_child_id, :_destroy],
      deity_creatures_attributes: [:id, :creature_id, :_destroy],
      deity_floras_attributes: [:id, :flora_id, :_destroy],
      deity_religions_attributes: [:id, :religion_id, :_destroy],
      deity_relics_attributes: [:id, :relic_id, :_destroy],
      deity_abilities_attributes: [:id, :ability_id, :_destroy],
      deity_related_towns_attributes: [:id, :related_town_id, :_destroy],
      deity_related_landmarks_attributes: [:id, :related_landmark_id, :_destroy]
    ]
  end
end
