class ReligionsController < ContentController
  private

  def content_params
    params.require(:religion).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description other_name universe_id
      origin_story
      teachings prophecies places_of_worship worship_services obligations paradise
      initiation rituals holidays
      notes private_notes
    ) + [
      custom_attribute_values:             [:name, :value],
      religious_figureships_attributes:    [:id, :notable_figure_id, :_destroy],
      deityships_attributes:               [:id, :deity_id, :_destroy],
      religious_locationships_attributes:  [:id, :practicing_location_id, :_destroy],
      artifactships_attributes:            [:id, :artifact_id, :_destroy],
      religious_raceships_attributes:      [:id, :race_id, :_destroy]
    ]
  end
end
