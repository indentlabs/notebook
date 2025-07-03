class AttributeFieldsController < ContentController
  before_action :authenticate_user!
  before_action :set_attribute_field, only: [:update, :edit]

  def create
    if initialize_object.save!
      @content = @attribute_field if @attribute_field
      @content ||= initialize_object
      
      message = "Nifty new #{@content.label} field created!"
      successful_response(@content, message)
    else
      failed_response(
        'create',
        :unprocessable_entity,
        "Unable to create field. Error code: " + (@content&.errors&.to_json || 'Unknown error')
      )
    end
  end

  def destroy
    # Delete this field as usual -- sets @content
    super

    # If the related category is now empty, delete it as well
    related_category = @content.attribute_category
    related_category.destroy if related_category.attribute_fields.empty?
  end

  def edit
    unless @attribute_field.readable_by?(current_user)
      render json: { error: "You don't have permission to edit that!" }, status: :forbidden
      return
    end
    
    content_type_class = @attribute_field.attribute_category.entity_type.classify.constantize
    render partial: 'content/attributes/tailwind/field_config', locals: { 
      field: @attribute_field,
      content_type_class: content_type_class,
      content_type: @attribute_field.attribute_category.entity_type.downcase
    }
  end

  def update
    unless @attribute_field.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: root_path
    end

    # Clean up field_options to handle empty linkable_types arrays properly
    cleaned_params = content_params.dup
    if cleaned_params[:field_options] && cleaned_params[:field_options][:linkable_types]
      # Remove empty strings from linkable_types array
      cleaned_params[:field_options][:linkable_types] = cleaned_params[:field_options][:linkable_types].reject(&:blank?)
    end

    if @attribute_field.update(cleaned_params.merge({ migrated_from_legacy: true }))
      @content = @attribute_field
      
      # Generate specific message based on what was updated
      message = if content_params[:hidden] && content_params[:hidden] == 'true'
        "#{@attribute_field.label} field is now hidden"
      elsif content_params[:hidden] && content_params[:hidden] == 'false'
        "#{@attribute_field.label} field is now visible"
      elsif content_params[:position]
        "#{@attribute_field.label} field moved to position #{content_params[:position]}"
      else
        "#{@attribute_field.label} field updated successfully!"
      end
      
      successful_response(@attribute_field, message)
    else
      failed_response(
        'edit', 
        :unprocessable_entity, 
        "Unable to save page. Error code: " + @attribute_field.errors.to_json
      )
    end
  end

  def suggest
    entity_type = params.fetch(:content_type, '').downcase
    category = params.fetch(:category, '')
    
    suggestions = AttributeFieldSuggestion.where(
      entity_type: entity_type,
      category_label: category
    ).where.not(suggestion: [nil, ""]).order('weight desc').limit(
      AttributeFieldSuggestion::SUGGESTIONS_RESULT_COUNT
    ).pluck(:suggestion).uniq

    if suggestions.empty?
      CacheMostUsedAttributeFieldsJob.perform_later(entity_type, category)
    end

    render json: suggestions
  end

  private

  def initialize_object
    @attribute_field = AttributeField.find_or_initialize_by(content_params.except(:field_options)).tap do |field|
      field.user_id = current_user.id
      
      # Clean up field_options to handle empty linkable_types arrays properly
      field_options = content_params.fetch(:field_options, {})
      if field_options[:linkable_types]
        field_options[:linkable_types] = field_options[:linkable_types].reject(&:blank?)
      end
      field.field_options = field_options
      
      field.migrated_from_legacy = true
    end

    if @attribute_field.attribute_category_id.nil?
      category = current_user.attribute_categories.where(id: content_params[:attribute_category_id]).first

      if category.nil?
        category = current_user.attribute_categories.where(label: content_params[:attribute_category] || content_params[:label]).first_or_initialize.tap do |c|
          c.entity_type = params[:entity_type] || content_params[:entity_type]
          c.save!
        end
      end

      @attribute_field.attribute_category_id = category.id
    end

    @attribute_field
  end

  def content_deletion_redirect_url
    :back
  end

  def content_creation_redirect_url
    if @content.present?
      category = @content.attribute_category
      attribute_customization_tailwind_path(content_type: category.entity_type)
    else
      :back
    end
  end

  def successful_response(record, notice)
    respond_to do |format|
      format.html { 
        redirect_to attribute_customization_tailwind_path(content_type: record.attribute_category.entity_type), notice: notice 
      }
      format.json { 
        # Get the content type class for the partial
        content_type_class = record.attribute_category.entity_type.classify.constantize
        
        # Create a temporary HTML response context to render the partial
        field_html = nil
        begin
          # Force the lookup context to use HTML templates
          old_formats = lookup_context.formats
          lookup_context.formats = [:html]
          
          field_html = render_to_string(
            partial: 'content/attributes/tailwind/field_item',
            locals: {
              field: record,
              content_type_class: content_type_class,
              content_type: record.attribute_category.entity_type.downcase
            }
          )
        ensure
          # Restore original formats
          lookup_context.formats = old_formats
        end
        
        response_data = { 
          success: true, 
          message: notice, 
          field: {
            id: record.id,
            hidden: record.hidden,
            label: record.label,
            field_type: record.field_type,
            attribute_category_id: record.attribute_category_id,
            position: record.position
          },
          html: field_html
        }
        render json: response_data, status: :ok 
      }
    end
  end

  def failed_response(action, status, message)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.json { render json: { success: false, error: message }, status: status }
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
      :hidden, :position,
      field_options: {
        linkable_types: []
      }
    ]
  end

  private

  def set_attribute_field
    @attribute_field = current_user.attribute_fields.find_by(params.permit(:id))
  end
end
