class MagicsController < ContentController
  private

  def content_params
    params.require(:magic).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description type_of universe_id visuals effects positive_effects
      negative_effects neutral_effects element resource_costs materials
      skills_required limitations notes private_notes
    ) + [
      magic_deityships_attributes: [:id, :deity_id, :_destroy]
    ]
  end
end
