# Controller for the Location model
class LocationsController < ContentController
  autocomplete :location, :name

  private

  def content_param_list
    [
      :universe_id, :user_id, :name, :type_of, :description, #:map,
      :population, :currency, :motto, :language,
      :area, :crops, :located_at, :established_year, :notable_wars,
      :notes, :private_notes, :privacy, :laws, :climate, :founding_story,
      :sports,

      # Relations
      #todo might be able to inject/reflect these from :relates concern implementation
      #todo why are capital/largest/notable relationships doubled up here? 
      custom_attribute_values:                   [:name, :value],
      location_leaderships_attributes:           [:id, :leader_id,       :_destroy],
      capital_cities_relationships_attributes:   [:id, :capital_city_id, :_destroy],
      largest_cities_relationships_attributes:   [:id, :largest_city_id, :_destroy],
      notable_cities_relationships_attributes:   [:id, :notable_city_id, :_destroy],
      location_languageships_attributes:         [:id, :language_id,     :_destroy],
      location_capital_towns_attributes:         [:id, :capital_town_id, :_destroy],
      location_largest_towns_attributes:         [:id, :largest_town_id, :_destroy],
      location_notable_towns_attributes:         [:id, :notable_town_id, :_destroy],
      location_landmarks_attributes:             [:id, :landmark_id, :_destroy]
    ]
  end
end
