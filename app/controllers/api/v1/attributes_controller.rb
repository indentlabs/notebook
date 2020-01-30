module Api
  module V1
    class AttributesController < ApiController
      def suggest
        entity_type = params[:entity_type]
        field_label = params[:field_label]
        return unless Rails.application.config.content_types[:all].map(&:name).include?(entity_type)

        field_ids = AttributeField.where(
          label:      field_label,
          field_type: 'text_area'
        ).pluck(:id)

        # This is too slow. Need DB indexes?
        # suggestions = Attribute.where(attribute_field_id: field_ids, entity_type: entity_type)
        #   .where.not(value: [nil, ""])
        #   .group(:value)
        #   .order('count_id DESC')
        #   .limit(50)
        #   .count(:id)
        #   .reject { |_, count| count < 1 }

        render json: suggestions.to_json
      end
    end
  end
end