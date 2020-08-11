module Api
  module V1
    class ApiController < ApplicationController
      before_action :authenticate_api_user!

      def authenticate_api_user!
        # authenticate API credentials and assign @current_api_user
        @current_api_user = current_user
      end

      # Content page list endpoints
      Rails.application.config.content_types[:all].each do |content_type|
        define_method(content_type.name.downcase.pluralize) do
          pages = @current_api_user.send(content_type.name.downcase.pluralize)

          render json: pages.map { |page|
            {
              id:          page.id,
              name:        page.name,
              description: page.description,
              universe:    page.universe.nil? ? nil : {
                id:   page.universe_id,
                name: page.universe.name
              },
              meta: {
                created_at: page.created_at,
                updated_at: page.updated_at
              }
            }
          }
        end
      end

      # Content page show endpoints
      Rails.application.config.content_types[:all].each do |content_type|
        define_method(content_type.name.downcase) do
          page = content_type.find_by(id: params[:id])

          if page && page.readable_by?(@current_api_user || User.new)
            render json: ApiContentSerializer.new(page, include_blank_fields: params.fetch(:include_blank_fields, false)).data
          else
            render json: { error: "Page not found" }
          end
        end
      end
    end
  end
end