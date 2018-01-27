class RacesController < ContentController
  private

  def content_param_list
    %i(
      name description other_names universe_id
      body_shape skin_colors height weight notable_features variance clothing
      strengths weaknesses privacy
      traditions beliefs governments technologies occupations economics favorite_foods
      notable_events
      notes private_notes
    ) + [
      custom_attribute_values:          [:name, :value],
      famous_figureships_attributes:    [:id, :famous_figure_id, :_destroy]
    ]
  end
end
