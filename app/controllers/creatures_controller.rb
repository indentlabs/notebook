class CreaturesController < ContentController
  private

  def content_params
    params.require(:creature).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description type_of other_names universe_id color shape size notable_features
      materials preferred_habitat sounds strengths weaknesses spoils aggressiveness
      attack_method defense_method maximum_speed food_sources
      migratory_patterns reproduction herd_patterns
      similar_animals symbolisms privacy
    ) + [
      wildlifeships_attributes:     [:id, :habitat_id, :_destroy],
    ]
  end
end
