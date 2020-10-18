
class BuildingsController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :privacy, :page_type
    ] + [ #<relations>
      custom_attribute_values:              [:name, :value],
      building_towns_attributes:            [:id, :town_id, :_destroy],
      building_countries_attributes:        [:id, :country_id, :_destroy],
      building_landmarks_attributes:        [:id, :landmark_id, :_destroy],
      building_locations_attributes:        [:id, :location_id, :_destroy],
      building_nearby_buildings_attributes: [:id, :nearby_building_id, :_destroy],
      building_schools_attributes:          [:id, :district_school_id, :_destroy]
    ]
  end
end
