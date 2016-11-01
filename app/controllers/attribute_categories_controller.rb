# Controller for the Attribute model
class AttributeCategoriesController < ContentController
  private

  def content_params
    params.require(:attribute_category).permit(content_param_list)
  end

  def content_param_list
    [
      :user_id, :entity_type,
      :name, :label, :icon, :description
    ]
  end
end
