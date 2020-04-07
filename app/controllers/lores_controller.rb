class LoresController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :archived_at, :privacy, :favorite, :page_type
    ] + [ #<relations>
      custom_attribute_values:           [:name, :value],

      lore_planets_attributes: [:id, :planet_id, :_destroy],
      lore_countries_attributes: [:id, :country_id, :_destroy],
      lore_continents_attributes: [:id, :continent_id, :_destroy],
      lore_landmarks_attributes: [:id, :landmark_id, :_destroy],
      lore_towns_attributes: [:id, :town_id, :_destroy],
      lore_buildings_attributes: [:id, :building_id, :_destroy],
      lore_schools_attributes: [:id, :school_id, :_destroy],
      lore_characters_attributes: [:id, :character_id, :_destroy],
      lore_deities_attributes: [:id, :deity_id, :_destroy],
      lore_creatures_attributes: [:id, :creature_id, :_destroy],
      lore_floras_attributes: [:id, :flora_id, :_destroy],
      lore_jobs_attributes: [:id, :job_id, :_destroy],
      lore_technologies_attributes: [:id, :technology_id, :_destroy],
      lore_vehicles_attributes: [:id, :vehicle_id, :_destroy],
      lore_conditions_attributes: [:id, :condition_id, :_destroy],
      lore_races_attributes: [:id, :race_id, :_destroy],
      lore_religions_attributes: [:id, :religion_id, :_destroy],
      lore_magics_attributes: [:id, :magic_id, :_destroy],
      lore_governments_attributes: [:id, :government_id, :_destroy],
      lore_groups_attributes: [:id, :group_id, :_destroy],
      lore_traditions_attributes: [:id, :tradition_id, :_destroy],
      lore_foods_attributes: [:id, :food_id, :_destroy],
      lore_sports_attributes: [:id, :sport_id, :_destroy],
      lore_believers_attributes: [:id, :believer_id, :_destroy],
      lore_created_traditions_attributes: [:id, :created_tradition_id, :_destroy],
      lore_original_languages_attributes: [:id, :original_language_id, :_destroy],
      lore_variations_attributes: [:id, :variation_id, :_destroy],
      lore_related_lores_attributes: [:id, :related_lore_id, :_destroy]
    ]
  end
end
