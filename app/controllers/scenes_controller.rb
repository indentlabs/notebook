class ScenesController < ContentController
  private

  def content_params
    params.require(:scene).permit(content_param_list)
  end

  def content_param_list
    %i(
      name summary universe_id
      cause description results
      notes private_notes
    ) + [
      scene_characterships_attributes:  [:id, :scene_character_id, :_destroy],
      scene_locationships_attributes:   [:id, :scene_location_id, :_destroy],
      scene_itemships_attributes:       [:id, :scene_item_id, :_destroy],
    ]
  end
end
