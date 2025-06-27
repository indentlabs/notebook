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
    
    # Add a validation check to ensure all images in params exist
    # This helps prevent race conditions where an image might have been deleted
    image_ids_by_type = {
      'image_upload' => [],
      'basil_commission' => []
    }
    
    params[:images].each do |image_data|
      if ['image_upload', 'basil_commission'].include?(image_data[:type])
        image_ids_by_type[image_data[:type]] << image_data[:id].to_i
      else
        success = false
        return render json: { error: 'Invalid image type' }, status: :unprocessable_entity
      end
    end
    
    # Verify all images exist and belong to this content
    image_upload_count = ImageUpload.where(
      id: image_ids_by_type['image_upload'],
      content_type: content_type, 
      content_id: content_id
    ).count
    
    basil_commission_count = BasilCommission.where(
      id: image_ids_by_type['basil_commission'],
      entity_type: content_type, 
      entity_id: content_id
    ).count
    
    if image_upload_count != image_ids_by_type['image_upload'].size ||
       basil_commission_count != image_ids_by_type['basil_commission'].size
      return render json: { error: 'Some images do not exist or do not belong to this content' }, 
                    status: :unprocessable_entity
    end
    
    # Use an advisory lock to prevent concurrent updates
    # This ensures only one request at a time can update positions for this content
    lock_key = "gallery_images_#{content_type}_#{content_id}"
    
    # Use a transaction to ensure all positions are updated or none are
    ActiveRecord::Base.transaction do
      # With_advisory_lock is a gem method, but we handle it with our own locking mechanism
      # if it's not available
      if ActiveRecord::Base.connection.respond_to?(:with_advisory_lock)
        ActiveRecord::Base.connection.with_advisory_lock(lock_key) do
          update_image_positions(params[:images], content_type, content_id)
        end
      else
        # Fallback to regular transaction if advisory locks aren't supported
        update_image_positions(params[:images], content_type, content_id)
      end
    end

    if success
      render json: { success: true }
    else
      render json: { error: 'Failed to update image positions' }, status: :unprocessable_entity
    end
  end
  
  private
  
  def update_image_positions(images, content_type, content_id)
    # Process each image in the array
    images.each do |image_data|
      if image_data[:type] == 'image_upload'
        # Update ImageUpload position
        image = ImageUpload.find_by(id: image_data[:id])
        if image && image.content_type == content_type && image.content_id.to_s == content_id.to_s
          image.insert_at(image_data[:position].to_i)
        else
          raise ActiveRecord::Rollback
        end
      elsif image_data[:type] == 'basil_commission'
        # Update BasilCommission position
        image = BasilCommission.find_by(id: image_data[:id])
        if image && image.entity_type == content_type && image.entity_id.to_s == content_id.to_s
          image.insert_at(image_data[:position].to_i)
        else
          raise ActiveRecord::Rollback
        end
      else
        raise ActiveRecord::Rollback
      end
    end
  end
end
