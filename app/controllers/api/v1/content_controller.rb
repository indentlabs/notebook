module Api
  module V1
    class ContentController < ApiController
      before_action :authenticate_user!
      
      def sort
        sortable_class = params[:sortable_class]
        content_id = params[:content_id]
        intended_position = params[:intended_position].to_i
        
        if sortable_class == 'AttributeCategory'
          category = AttributeCategory.find(content_id)
          authorize_action_for category
          
          # Update category position
          category.update(position: intended_position)
          
          render json: { status: :ok }
        elsif sortable_class == 'AttributeField'
          field = AttributeField.find(content_id)
          authorize_action_for field
          
          # Update field position
          field.update(position: intended_position)
          
          render json: { status: :ok }
        else
          render json: { status: :error, message: 'Invalid sortable class' }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { status: :error, message: 'Record not found' }, status: :not_found
      rescue StandardError => e
        render json: { status: :error, message: e.message }, status: :internal_server_error
      end
    end
  end
end