module Api
  module V1
    class AttributeCategoriesController < ApiController
      before_action :authenticate_user!, only: [:edit]
      before_action :set_category, only: [:edit]
      
      def suggest
        # Handle both :content_type (from /api/v1/categories/suggest/:content_type) 
        # and :entity_type (from other routes) for backward compatibility
        entity_type = params.fetch(:content_type, params.fetch(:entity_type, '')).downcase
        
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
      
      def edit
        authorize_action_for @category
        content_type_class = @category.entity_type.constantize
        render partial: 'content/attributes/tailwind/category_config', locals: { 
          category: @category,
          content_type_class: content_type_class,
          content_type: @category.entity_type.downcase
        }
      end
      
      private
      
      def set_category
        @category = AttributeCategory.find(params[:id])
      end
    end
  end
end