# Controller for the Attribute model
class AttributeCategoriesController < ContentController
  def create
    initialize_object.save!
    redirect_to(
      attribute_customization_path(content_type: @content.entity_type),
      notice: "Shiny new #{@content.label} category created!"
    )
  end

  private

  def successful_response(url, notice)
    respond_to do |format|
      format.html { redirect_to attribute_customization_path(content_type: @content.entity_type), notice: notice }
      format.json { render json: @content || {}, status: :success, notice: notice }
    end
  end

  def content_params
    params.require(:attribute_category).permit(content_param_list)
  end

  def content_param_list
    [
      :user_id, :entity_type,
      :name, :label, :icon, :description,
      :hidden
    ]
  end
end
