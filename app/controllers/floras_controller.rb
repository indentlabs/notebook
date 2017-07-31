class FlorasController < ContentController
  private

  def content_params
    params.require(:flora).permit(content_param_list)
  end

  def content_param_list
    binding.pry
    %i(
      name description aliases universe_id
      order family genus
      colorings size smell taste
      fruits seeds nuts berries medicinal_purposes
      reproduction seasonality
      notes private_notes
    ) + [
      custom_attribute_values:           [:name, :value],
      flora_relationships_attributes:    [:id, :related_flora_id, :_destroy],
      flora_magical_effects_attributes:  [:id, :magic_id, :_destroy],
      flora_locations_attributes:        [:id, :location_id, :_destroy],
      flora_eaten_by_attributes:         [:id, :creature_id, :_destroy],
    ]
  end
end
