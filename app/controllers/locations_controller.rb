# Controller for the Location model
class LocationsController < ContentController
  autocomplete :location, :name

  private

  def content_params
    params.require(:location).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id, :name, :type_of, :description, #:map,
      :population, :currency, :motto,
      :area, :crops, :located_at, :established_year, :notable_wars,
      :notes, :private_notes, :privacy,

      # Relations
      #todo might be able to inject/reflect these from :relates concern implementation
      location_leaderships_attributes:           [:id, :leader_id,       :_destroy],
      capital_cities_relationships_attributes:   [:id, :capital_city_id, :_destroy],
      largest_cities_relationships_attributes:   [:id, :largest_city_id, :_destroy],
      notable_cities_relationships_attributes:   [:id, :notable_city_id, :_destroy]
    ]
  end
end
