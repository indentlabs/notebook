class AttributeFieldsController < ContentController
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
    content_type = AttributeField
    # todo rework from here

    content_type = content_type_from_controller(self.class)
    @content = content_type.with_deleted.find(params[:id])

    unless @content.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: @content
    end

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'updated content', {
      'content_type': content_type.name
    }) if Rails.env.production?

    if params.key?('image_uploads')
      upload_files(params['image_uploads'], content_type.name, @content.id)
    end

    if @content.is_a?(Universe) && params.key?('contributors') && @content.user == current_user
      params[:contributors][:email].reject(&:blank?).each do |email|
        ContributorService.invite_contributor_to_universe(universe: @content, email: email.downcase)
      end
    end

    update_page_tags if @content.respond_to?(:page_tags) 

    if @content.user == current_user
      # todo this needs some extra validation probably to ensure each attribute is one associated with this page
      update_success = @content.reload.update(content_params)
    else
      # Exclude fields only the real owner can edit
      #todo move field list somewhere when it grows
      update_success = @content.update(content_params.except(:universe_id))
    end

    if update_success 
      successful_response(@content, t(:update_success, model_name: @content.try(:name).presence || humanized_model_name))
    else
      failed_response('edit', :unprocessable_entity, "Unable to save page. Error code: " + @content.errors.to_json)
    end
  end

  private

  def initialize_object
    @content = AttributeField.find_or_initialize_by(content_params).tap do |field|
      field.user_id    = current_user.id
      field.field_type = 'text_area'
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

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'created attribute field', {
      'content_type': params[:entity_type]
    }) if Rails.env.production?

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

  def content_param_list
    [
      :universe_id, :user_id,
      :attribute_category,
      :name, :field_type,
      :label, :description,
      :entity_type, 
      :attribute_category_id,
      :hidden,
      :field_options
    ]
  end
end
