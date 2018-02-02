class ScenesController < ContentController
  private

  def content_param_list
    %i(
      name summary universe_id
      cause description results
      notes private_notes privacy
    ) + [
      custom_attribute_values:          [:name, :value],
      scene_characterships_attributes:  [:id, :scene_character_id, :_destroy],
      scene_locationships_attributes:   [:id, :scene_location_id, :_destroy],
      scene_itemships_attributes:       [:id, :scene_item_id, :_destroy],
    ]
  end
end
