
class DeitiesController < ContentController
  private

  def content_param_list
    [
      :name, :description, :other_names, :physical_description, :height, :weight, :symbols, :elements, :strengths, :weaknesses, :prayers, :rituals, :human_interaction, :notable_events, :family_history, :life_story, :notes, :private_notes, :privacy, :universe_id
    ] + [ #<relations>

    ]
  end
end
    