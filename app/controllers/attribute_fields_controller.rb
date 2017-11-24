# Controller for the Attribute model
class AttributeFieldsController < ContentController
  def destroy
    # Delete this field as usual -- sets @content
    super

    # If the related category is now empty, delete it as well
    related_category = @content.attribute_category
    related_category.destroy if related_category.attribute_fields.empty?
  end

  private

  def initialize_object
    category = current_user.attribute_categories.where(label: content_params[:attribute_category]).first_or_initialize.tap do |c|
      c.entity_type = params[:entity_type]
      c.save!
    end

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'created attribute', {
      'content_type': params[:entity_type]
    }) if Rails.env.production?

    @content = AttributeField.new(label: content_params[:label]).tap do |f|
      f.attribute_category_id = category.id
      f.user_id = current_user.id
      f.field_type = 'textearea'
    end
  end

  def content_deletion_redirect_url
    :back
  end

  def content_creation_redirect_url
    :back
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
