module Api
  module Internal
    class ApiController < ApplicationController
      before_action :sanitize_content_type
      before_action :set_content

      def name_lookup
        render body: viewable_content.try(:name) || 'Page not found', content_type: 'text/plain'
      end

      private

      # A document's title can give away what's in it, so it's only for people who can read it
      def viewable_content
        return @content unless @content.is_a?(Document)

        @content if @content.readable_by?(current_user || User.new)
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