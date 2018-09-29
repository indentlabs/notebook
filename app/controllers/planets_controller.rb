class PlanetsController < ContentController
  private

  def content_param_list
    [
      :name, :description, :size, :surface, :landmarks, :climate, :weather,
      :water_content, :natural_resources, :length_of_day, :length_of_night,
      :calendar_system, :population, :moons, :orbit, :visible_constellations,
      :first_inhabitants_story, :world_history, :public_notes, :private_notes,
      :privacy, :universe_id
    ] + [
      #todo refactor all models to use:
      # self.class.relates.map do |relation|
      #   #{with_relation}_attributes: [:id, :#{relates_relation.singularize}_id, :_destroy]
      # end
      planet_countries_attributes: [:id, :country_id, :_destroy],
      planet_locations_attributes: [:id, :location_id, :_destroy],
      planet_landmarks_attributes: [:id, :landmark_id, :_destroy],
      planet_races_attributes: [:id, :race_id, :_destroy],
      planet_floras_attributes: [:id, :flora_id, :_destroy],
      planet_creatures_attributes: [:id, :creature_id, :_destroy],
      planet_religions_attributes: [:id, :religion_id, :_destroy],
      planet_deities_attributes: [:id, :deity_id, :_destroy],
      planet_groups_attributes: [:id, :group_id, :_destroy],
      planet_languages_attributes: [:id, :language_id, :_destroy],
      planet_towns_attributes: [:id, :town_id, :_destroy],
      planet_nearby_planets_attributes: [:id, :nearby_planet_id, :_destroy],
      custom_attribute_values:     [:name, :value]
    ]
  end
end
