class CreaturesController < ContentController
  private

  def content_param_list
    %i(
      name description type_of other_names universe_id color shape size notable_features
      materials preferred_habitat sounds strengths weaknesses spoils aggressiveness
      attack_method defense_method maximum_speed food_sources
      migratory_patterns reproduction herd_patterns
      similar_animals symbolisms privacy notes private_notes
      phylum class_string order family genus species
    ) + [
      custom_attribute_values:      [:name, :value],
      wildlifeships_attributes:     [:id, :habitat_id, :_destroy],
      creature_relationships_attributes: [:id, :related_creature_id, :_destroy]
    ]
  end
end
