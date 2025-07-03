# Controller for the Attribute model
class AttributeCategoriesController < ContentController
  before_action :authenticate_user!
  before_action :set_attribute_category, only: [:edit, :update, :destroy]
  
  def edit
    unless @attribute_category.readable_by?(current_user)
      render json: { error: "You don't have permission to edit that!" }, status: :forbidden
      return
    end
    
    content_type_class = @attribute_category.entity_type.classify.constantize
    render partial: 'content/attributes/tailwind/category_config', locals: { 
      category: @attribute_category,
      content_type_class: content_type_class,
      content_type: @attribute_category.entity_type.downcase
    }
  end
  
  def create
    if initialize_object.save!
      @content = @attribute_category if @attribute_category
      @content ||= initialize_object
      
      message = "Shiny new #{@content.label} category created!"
      successful_response(@content, message)
    else
      failed_response(
        'create',
        :unprocessable_entity,
        "Unable to create category. Error code: " + (@content&.errors&.to_json || 'Unknown error')
      )
    end
  end

  def update
    unless @attribute_category.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: root_path
    end

    if @attribute_category.update(content_params)
      @content = @attribute_category
      
      # Generate specific message based on what was updated
      message = if content_params[:hidden] && content_params[:hidden] == 'true'
        "#{@attribute_category.label} category is now hidden"
      elsif content_params[:hidden] && content_params[:hidden] == 'false'
        "#{@attribute_category.label} category is now visible"
      elsif content_params[:position]
        "#{@attribute_category.label} category moved to position #{content_params[:position]}"
      else
        "#{@attribute_category.label} category updated successfully!"
      end
      
      successful_response(@attribute_category, message)
    else
      failed_response(
        'edit', 
        :unprocessable_entity, 
        "Unable to save category. Error code: " + @attribute_category.errors.to_json
      )
    end
  end

  def destroy
    unless @attribute_category.deletable_by?(current_user)
      respond_to do |format|
        format.html { 
          flash[:notice] = "You don't have permission to delete that!"
          redirect_back fallback_location: root_path
        }
        format.json { render json: { error: "You don't have permission to delete that!" }, status: :forbidden }
      end
      return
    end

    category_id = @attribute_category.id
    category_label = @attribute_category.label
    category_entity_type = @attribute_category.entity_type
    field_count = @attribute_category.attribute_fields.count
    
    # Delete the category (this will cascade delete all fields and their answers)
    @attribute_category.destroy
    
    respond_to do |format|
      format.html { 
        redirect_to(
          attribute_customization_tailwind_path(content_type: category_entity_type),
          notice: "#{category_label} category deleted!"
        )
      }
      format.json { 
        render json: { 
          success: true, 
          message: "#{category_label} category and its #{field_count} #{'field'.pluralize(field_count)} have been permanently deleted.",
          category_id: category_id
        }, status: :ok 
      }
    end
  end

  def suggest
    entity_type = params.fetch(:content_type, '').downcase
    
    suggestions = AttributeCategorySuggestion.where(entity_type: entity_type)
      .where.not(suggestion: AttributeCategorySuggestion::BLACKLISTED_LABELS)
      .order('weight desc')
      .limit(AttributeCategorySuggestion::SUGGESTIONS_RESULT_COUNT)
      .pluck(:suggestion)

    if suggestions.empty?
      CacheMostUsedAttributeCategoriesJob.perform_later(entity_type)
    end

    render json: suggestions
  end

  private

  def failed_response(action, status, message)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.json { render json: { error: message }, status: status }
    end
  end

  def successful_response(record, notice)
    respond_to do |format|
      format.html { 
        redirect_to attribute_customization_tailwind_path(content_type: record.entity_type), notice: notice 
      }
      format.json { 
        response_data = { 
          success: true, 
          message: notice, 
          category: {
            id: record.id,
            hidden: record.hidden,
            label: record.label,
            icon: record.icon,
            entity_type: record.entity_type,
            position: record.position
          }
        }
        render json: response_data, status: :ok 
      }
    end
  end

  def initialize_object
    @content = current_user.attribute_categories.find_or_initialize_by(content_params.except(:field_options)).tap do |category|
      category.user_id = current_user.id
    end
  end

  def content_params
    params.require(:attribute_category).permit(content_param_list)
  end

  def content_param_list
    [
      :user_id, :entity_type,
      :name, :label, :icon, :description,
      :hidden, :position
    ]
  end
  
  def set_attribute_category
    @attribute_category = current_user.attribute_categories.find(params[:id])
  end
end
