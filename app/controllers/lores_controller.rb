class LoresController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :archived_at, :privacy, :favorite, :page_type
    ] + [ #<relations>
      custom_attribute_values:           [:name, :value],

      lore_planets_attributes: [:id, :planet_id, :_destroy],

      siblingships_attributes:     [:id, :sibling_id, :_destroy],
    ]
  end
end
