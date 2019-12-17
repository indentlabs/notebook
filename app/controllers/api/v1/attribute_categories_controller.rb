module Api
  module V1
    class AttributeCategoriesController < ApiController
      def suggest
        suggestions = AttributeCategorySuggestion.where(
          entity_type:    params.fetch(:entity_type, '').downcase
        ).order('weight desc').limit(
          AttributeCategorySuggestion::SUGGESTIONS_RESULT_COUNT
        ).pluck(:suggestion, :weight)

        if suggestions.empty?
          CacheMostUsedAttributeCategoriesJob.perform_later(
            params.fetch(:entity_type, nil)
          )
        end

        render json: suggestions.to_json
      end
    end
  end
end