# Controller for the Attribute model
class AttributeFieldsController < ContentController

  def create
    initialize_object

    if @content.save
      successful_response(:back, t(:create_success, model_name: humanized_model_name))
    else
      failed_response('new', :unprocessable_entity)
    end
  end

  private

  def initialize_object
    category = current_user.attribute_categories.where(label: content_params[:attribute_category]).first_or_initialize.tap do |c|
      c.entity_type = params[:entity_type]
      c.save!
    end

    @content = AttributeField.new(label: content_params[:label]).tap do |f|
      f.attribute_category_id = category.id
      f.user_id = current_user.id
      f.field_type = 'textearea'
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
      :label, :description
    ]
  end
end
