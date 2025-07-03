module Api
  module V1
    class AttributeFieldsController < ApiController
      before_action :authenticate_user!, only: [:edit]
      before_action :set_field, only: [:edit]
      
      def suggest
        # Handle both :content_type (from /api/v1/fields/suggest/:content_type/:category) 
        # and :entity_type (from other routes) for backward compatibility
        entity_type = params.fetch(:content_type, params.fetch(:entity_type, '')).downcase
        category = params.fetch(:category, '')
        
        suggestions = AttributeFieldSuggestion.where(
          entity_type:    entity_type,
          category_label: category
        ).where.not(suggestion: [nil, ""]).order('weight desc').limit(
          AttributeFieldSuggestion::SUGGESTIONS_RESULT_COUNT
        ).pluck(:suggestion).uniq

        if suggestions.empty?
          CacheMostUsedAttributeFieldsJob.perform_later(entity_type, category)
        end

        render json: suggestions
      end
      
      def edit
        authorize_action_for @field
        content_type_class = @field.attribute_category.entity_type.constantize
        render partial: 'content/attributes/tailwind/field_config', locals: { 
          field: @field,
          content_type_class: content_type_class,
          content_type: @field.attribute_category.entity_type.downcase
        }
      end
      
      private
      
      def set_field
        @field = AttributeField.find(params[:id])
      end
    end
  end
end