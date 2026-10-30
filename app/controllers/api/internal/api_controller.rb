module Api
  module Internal
    class ApiController < ApplicationController
      before_action :sanitize_content_type
      before_action :set_content

      def name_lookup
        render body: page_name, content_type: 'text/plain'
      end

      private

      def page_name
        return 'Page not found' if @content.nil?
        return @content.name if @content.readable_by?(current_user || User.new)

        ContentFormatterService.private_label(@content.class)
      end

      def sanitize_content_type
        valid_types = Rails.application.config.content_types[:all] + [Timeline, Document]

        unless valid_types.map(&:name).include?(params[:page_type])
          raise "Invalid page type: #{params[:page_type]}"
        end

        @sanitized_content_type = params[:page_type].constantize
      end

      def set_content
        @content = @sanitized_content_type.find_by(id: params[:page_id])
      end
    end
  end
end