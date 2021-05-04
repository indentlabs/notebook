class AttributeFieldsController < ContentController
  before_action :authenticate_user!
  before_action :set_attribute_field, only: [:update]

  def create
    initialize_object.save!
    
    redirect_back(
      fallback_location: attribute_customization_path(content_type: @content.attribute_category.entity_type),
      notice: "Nifty new #{@content.label} field created!"
    )
  end

  def destroy
    # Delete this field as usual -- sets @content
    super

    # If the related category is now empty, delete it as well
    related_category = @content.attribute_category
    related_category.destroy if related_category.attribute_fields.empty?
  end

  def update
    unless @attribute_field.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: root_path
    end

    if @attribute_field.update(attribute_field_params.merge({ migrated_from_legacy: true }))
      @content = @attribute_field
      successful_response(
        @attribute_field, 
        t(:update_success, model_name: @attribute_field.label)
      )
    else
      failed_response(
        'edit', 
        :unprocessable_entity, 
        "Unable to save page. Error code: " + @attribute_field.errors.to_json
      )
    end
  end

  private

  def initialize_object
    @content = AttributeField.find_or_initialize_by(content_params).tap do |field|
      field.user_id = current_user.id
      field.migrated_from_legacy = true
    end

    if @content.attribute_category_id.nil?
      category = current_user.attribute_categories.where(id: content_params[:attribute_category_id]).first

      if category.nil?
        category = current_user.attribute_categories.where(label: content_params[:attribute_category] || content_params[:label]).first_or_initialize.tap do |c|
          c.entity_type = params[:entity_type] || content_params[:entity_type]
          c.save!
        end
      end

      @content.attribute_category_id = category.id
    end

    @content
  end

  def content_deletion_redirect_url
    :back
  end

  def content_creation_redirect_url
    if @content.present?
      category = @content.attribute_category
      attribute_customization_path(content_type: category.entity_type)
    else
      :back
    end
  end

  def successful_response(url, notice)
    respond_to do |format|
      format.html { redirect_to attribute_customization_path(content_type: @content.attribute_category.entity_type), notice: notice }
      format.json { render json: @content || {}, status: :success, notice: notice }
    end
  end

  def content_params
    params.require(:attribute_field).permit(content_param_list)
  end

  def attribute_field_params
    params.require(:attribute_field).permit(:id, :label, field_options: {})
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :attribute_category,
      :name, :field_type,
      :label, :description,
      :entity_type, 
      :attribute_category_id,
      :hidden,
      field_options: {}
    ]
  end

  private

  def set_attribute_field
    @attribute_field = current_user.attribute_fields.find_by(params.permit(:id))
  end
end
