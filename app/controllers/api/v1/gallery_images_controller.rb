class Api::V1::GalleryImagesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:sort]

  # POST /api/v1/gallery_images/sort
  # Handles sorting of gallery images (both ImageUploads and BasilCommissions)
  # Expected params:
  # - images: Array of hashes with:
  #   - id: Image ID
  #   - type: 'image_upload' or 'basil_commission'
  #   - position: New position
  # - content_type: Content type (e.g., 'Character')
  # - content_id: Content ID
  def sort
    # Validate ownership/contribution permissions for the content
    content_type = params[:content_type]
    content_id = params[:content_id]
    content = content_type.constantize.find_by(id: content_id)
    
    # Check permissions - must own or contribute to this content
    unless content && 
           (content.user_id == current_user.id || 
            (content.respond_to?(:universe_id) && 
             content.universe_id.present? && 
             current_user.contributable_universe_ids.include?(content.universe_id)))
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    # Process each image in the array
    success = true
    
    # Use a transaction to ensure all positions are updated or none are
    ActiveRecord::Base.transaction do
      params[:images].each do |image_data|
        if image_data[:type] == 'image_upload'
          # Update ImageUpload position
          image = ImageUpload.find_by(id: image_data[:id])
          if image && image.content_type == content_type && image.content_id.to_s == content_id.to_s
            image.insert_at(image_data[:position].to_i)
          else
            success = false
            raise ActiveRecord::Rollback
          end
        elsif image_data[:type] == 'basil_commission'
          # Update BasilCommission position
          image = BasilCommission.find_by(id: image_data[:id])
          if image && image.entity_type == content_type && image.entity_id.to_s == content_id.to_s
            image.insert_at(image_data[:position].to_i)
          else
            success = false
            raise ActiveRecord::Rollback
          end
        else
          success = false
          raise ActiveRecord::Rollback
        end
      end
    end

    if success
      render json: { success: true }
    else
      render json: { error: 'Failed to update image positions' }, status: :unprocessable_entity
    end
  end
end
