class ReligionsController < ContentController
  private

  def content_params
    params.require(:religion).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description other_name universe_id
      origin_story
      teachings prophecies places_of_worship worship_services obligations paradise
      initiation rituals holidays
      notes private_notes
    )
  end
end
