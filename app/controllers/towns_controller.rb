class TownsController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :laws, :sports, :politics,
      :founding_story, :established_year,
      :notes, :private_notes,
      :privacy,
      town_citizens_attributes:         [:id, :citizen_id, :_destroy],
      town_floras_attributes:           [:id, :flora_id, :_destroy],
      town_creatures_attributes:        [:id, :creature_id, :_destroy],
      town_groups_attributes:           [:id, :group_id, :_destroy],
      town_languages_attributes:        [:id, :language_id, :_destroy],
      town_countries_attributes:        [:id, :country_id, :_destroy],
      town_nearby_landmarks_attributes: [:id, :nearby_landmark_id, :_destroy]
    ]
  end
end
