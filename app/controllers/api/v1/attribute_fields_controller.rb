module Api
  module V1
    class AttributeFieldsController < ApiController
      def suggest
        category_label = params[:category]
        entity_type    = params.fetch(:entity_type, '').downcase

        category_query = AttributeCategory.where(label: category_label)
        category_query = category_query.where(entity_type: entity_type) unless entity_type.empty?
        
        suggestions = AttributeField.where(attribute_category_id: category_query.pluck(:id))
          .group(:label)
          .order('count_id DESC')
          .limit(50)
          .count(:id)
          .reject { |k, v| v < 10 }
          .keys

        render json: suggestions.to_json
      end
    end
  end
end