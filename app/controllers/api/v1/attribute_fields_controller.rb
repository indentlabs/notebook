module Api
  module V1
    class AttributeFieldsController < ApiController
      def suggest
        suggestions = AttributeFieldSuggestion.where(
          entity_type:    params.fetch(:entity_type, '').downcase,
          category_label: params.fetch(:category,    '')
        ).where.not(suggestion: [nil, ""]).order('weight desc').limit(
          AttributeFieldSuggestion::SUGGESTIONS_RESULT_COUNT
        ).pluck(:suggestion).uniq

        if suggestions.empty?
          CacheMostUsedAttributeFieldsJob.perform_later(
            params.fetch(:entity_type, nil),
            params.fetch(:category,    nil)
          )
        end

        render json: suggestions.to_json
      end
    end
  end
end