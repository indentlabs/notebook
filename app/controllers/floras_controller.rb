class FlorasController < ContentController
  private

  def content_params
    params.require(:flora).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description aliases universe_id
      order family genus
      colorings size smell taste
      fruits seeds nuts berries medicinal_purposes
      reproduction seasonality
      notes private_notes
    ) + [
      custom_attribute_values:     [:name, :value],
    ]
  end
end
