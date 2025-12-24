module Api
  module V1
    class PageNamesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def show
        page_type = params[:type]
        page_id = params[:id]

        return render json: { error: 'Missing type or id parameter' }, status: 400 unless page_type.present? && page_id.present?

        # Validate page type
        unless Rails.application.config.content_type_names[:all].include?(page_type) || 
               ['Document', 'Timeline'].include?(page_type)
          return render json: { error: 'Invalid page type' }, status: 400
        end

        # Find the page
        begin
          klass = page_type.constantize
          page = klass.find_by(id: page_id)
          
          # Check if page exists and user has access
          if page.nil?
            return render json: { error: 'Page not found' }, status: 404
          end

          unless page.readable_by?(current_user)
            return render json: { error: 'Access denied' }, status: 403
          end

          # Get the page name
          page_name = if page.respond_to?(:label) && page.label.present?
                        page.label
                      elsif page.respond_to?(:name) && page.name.present?
                        page.name
                      elsif page.respond_to?(:title) && page.title.present?
                        page.title
                      else
                        "Unnamed #{page_type}"
                      end

          render json: { name: page_name }
        rescue => e
          render json: { error: "Error loading page name: #{e.message}" }, status: 500
        end
      end
    end
  end
end