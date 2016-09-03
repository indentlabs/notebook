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
      :population, :currency, :motto, :capital,
      :area, :crops, :located_at, :established_year, :notable_wars,
      :notes, :private_notes,

      # Relations
      largest_cities_relationships_attributes:   [:id, :largest_city_id, :_destroy],
      notable_cities_relationships_attributes:   [:id, :notable_city_id, :_destroy]
    ]
  end
end
