class CountriesController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :population, :currency, :laws, :sports,
      :area, :crops, :climate,
      :founding_story, :established_year, :notable_wars,
      :notes, :private_notes,
      :privacy,
      country_towns_attributes:     [:id, :town_id, :_destroy],
      country_locations_attributes: [:id, :location_id, :_destroy],
      country_languages_attributes: [:id, :language_id, :_destroy],
      country_religions_attributes: [:id, :religion_id, :_destroy],
      country_landmarks_attributes: [:id, :landmark_id, :_destroy],
      country_creatures_attributes: [:id, :creature_id, :_destroy],
      country_floras_attributes:    [:id, :flora_id, :_destroy]
    ]
  end
end
