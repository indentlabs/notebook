# Controller for the Attribute model
class AttributeFieldsController < ContentController
  private

  def content_params
    params.require(:attribute_field).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :attribute_category_id,
      :name, :field_type,
      :label, :description
    ]
  end
end
