class LandmarksController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :size, :materials, :colors,
      :creation_story, :established_year,
      :notes, :private_notes,
      :privacy,
      landmark_nearby_towns_attributes: [:id, :nearby_town_id, :_destroy],
      landmark_countries_attributes:    [:id, :country_id, :_destroy],
      landmark_floras_attributes:       [:id, :flora_id, :_destroy],
      landmark_creatures_attributes:    [:id, :creature_id, :_destroy]
    ]
  end
end
