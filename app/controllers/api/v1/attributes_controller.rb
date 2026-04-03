module Api
  module V1
    class AttributesController < ApiController
      before_action :authenticate_user!
      
      # Category endpoints
      def category_edit
        @category = AttributeCategory.find(params[:id])
        authorize_action_for @category
        
        @content_type_class = @category.entity_type.constantize
        
        render partial: 'content/attributes/tailwind/category_config', locals: {
          category: @category,
          content_type_class: @content_type_class,
          content_type: @category.entity_type.downcase
        }
      end
      
      # Field endpoints
      def field_edit
        @field = AttributeField.find(params[:id])
        authorize_action_for @field
        
        @category = @field.attribute_category
        @content_type_class = @category.entity_type.constantize
        
        render partial: 'content/attributes/tailwind/field_config', locals: {
          field: @field,
          content_type_class: @content_type_class,
          content_type: @category.entity_type.downcase
        }
      end
      
      # Sort endpoint (handles both categories and fields)
      def sort
        sortable_class = params[:sortable_class]
        content_id = params[:content_id]
        intended_position = params[:intended_position].to_i
        
        if sortable_class == 'AttributeCategory'
          category = AttributeCategory.find(content_id)
          authorize_action_for category
          
          # Update category position
          category.update(position: intended_position)
          
          # Update other categories' positions
          categories = category.user.attribute_categories
                              .where(entity_type: category.entity_type)
                              .where.not(id: category.id)
                              .order(:position)
          
          # Reposition categories
          position = 0
          categories.each do |c|
            position += 1
            position += 1 if position == intended_position
            c.update_columns(position: position)
          end
          
          render json: { success: true }
        elsif sortable_class == 'AttributeField'
          field = AttributeField.find(content_id)
          authorize_action_for field
          
          # Check if field is moving to a different category
          if params[:attribute_category_id].present? && 
             field.attribute_category_id.to_s != params[:attribute_category_id].to_s
            
            # Update field's category
            new_category = AttributeCategory.find(params[:attribute_category_id])
            authorize_action_for new_category
            
            field.update(attribute_category_id: new_category.id, position: intended_position)
            
            # Update positions in the new category
            fields = new_category.attribute_fields
                               .where.not(id: field.id)
                               .order(:position)
            
            position = 0
            fields.each do |f|
              position += 1
              position += 1 if position == intended_position
              f.update_columns(position: position)
            end
          else
            # Just update position within current category
            field.update(position: intended_position)
            
            # Update other fields' positions
            fields = field.attribute_category.attribute_fields
                          .where.not(id: field.id)
                          .order(:position)
            
            position = 0
            fields.each do |f|
              position += 1
              position += 1 if position == intended_position
              f.update_columns(position: position)
            end
          end
          
          render json: { success: true }
        else
          render json: { error: "Invalid sortable class" }, status: :unprocessable_entity
        end
      end
      
      # API suggestion endpoint
      def suggest
        # For compatibility with existing code
        entity_type = params[:entity_type]
        field_label = params[:field_label]
        return unless Rails.application.config.content_types[:all].map(&:name).include?(entity_type)

        field_ids = AttributeField.where(
          label:      field_label,
          field_type: 'text_area'
        ).pluck(:id)
        
        # Return sample suggestions for now
        suggestions = ["Example 1", "Example 2", "Example 3"]

        render json: suggestions
      end
    end
  end
end