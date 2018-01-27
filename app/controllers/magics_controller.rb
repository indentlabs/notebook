class MagicsController < ContentController
  private

  def content_param_list
    %i(
      name description type_of universe_id visuals effects positive_effects
      negative_effects neutral_effects element resource_costs materials
      skills_required limitations notes private_notes privacy
    ) + [
      custom_attribute_values:     [:name, :value],
      magic_deityships_attributes: [:id, :deity_id, :_destroy]
    ]
  end
end
