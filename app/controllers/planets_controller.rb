
class PlanetsController < ContentController
  private

  def content_param_list
    [
      :name, :description, :size, :surface, :landmarks, :climate, :weather, :water_content, :natural_resources, :length_of_day, :length_of_night, :calendar_system, :population, :moons, :orbit, :visible_constellations, :first_inhabitants_story, :world_history, :public_notes, :private_notes, :privacy, :universe_id
    ] + [ #<relations>

    ]
  end
end
    
