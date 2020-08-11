module Api
  module V1
    class ApiController < ApplicationController
      # Content page list endpoints

      # Content page show endpoints
      Rails.application.config.content_types[:all].each do |content_type|
        define_method(content_type.name.downcase) do
          page = content_type.find_by(id: params[:id])

          if page && page.readable_by?(current_user || User.new)
            render json: ApiContentSerializer.new(page).data
          else
            render json: { error: "Page not found" }
          end
        end
      end
    end
  end
end