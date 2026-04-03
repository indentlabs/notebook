class ImageUploadController < ApplicationController
  def create
  end

  def delete
    image_id = params[:id]

    begin
      image = ImageUpload.find(image_id)
    rescue
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'Image not found.' }
        format.all { render json: { error: 'Image not found' }, status: 400 }
      end
      return
    end

    #todo authorizer for ImageUploads
    if current_user.nil? || current_user.id != image.user.id
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'Unauthorized.' }
        format.all { render json: { error: 'Unauthorized' }, status: 401 }
      end
      return
    end

    reclaimed_space_kb = image.src_file_size / 1000.0

    # If the user has access to delete the image, go for it
    result = image.destroy

    # And credit that space back to their bandwidth
    current_user.update(upload_bandwidth_kb: current_user.upload_bandwidth_kb + reclaimed_space_kb)

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'Image successfully deleted.' }
      format.all { render json: { success: result }, status: 200 }
    end
  end

  def update
    image_id = params[:id]

    begin
      image = ImageUpload.find(image_id)
    rescue
      render json: { error: 'Image not found' }, status: 404
      return
    end

    #todo authorizer for ImageUploads
    if current_user.nil? || current_user.id != image.user.id
      render json: { error: 'Unauthorized' }, status: 401
      return
    end

    if image.update(image_upload_params)
      render json: { success: true, notes: image.notes }, status: 200
    else
      render json: { error: 'Could not update image' }, status: 422
    end
  end

  private

  def image_upload_params
    params.require(:image_upload).permit(:notes)
  end
end
