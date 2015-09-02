# Controller for the Location model
class LocationsController < ContentController
  private

  def content_params
    params.require(:location).permit(
      :universe_id, :user_id, :name, :type_of, :description, :map,
      :population, :currency, :motto, :capital, :largest_city, :notable_cities,
      :area, :crops, :located_at, :stablishment_year, :notable_wars,
      :notes, :private_notes)
  end

  def create_location_from_params
    location = Location.new(location_params)
    location.user_id = session[:user]
    location.universe = universe_from_location_params
    location
  end

  def update_location_from_params
    params[:location][:universe] = universe_from_location_params
    Location.find(params[:id])
  end

  def universe_from_location_params
    Universe.where(user_id: session[:user], name: params[:location][:universe].strip).first
  end
end
