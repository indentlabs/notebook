class ImageUploadController < ApplicationController
  def create
  end

  def delete
    image_id = params[:id]

    begin
      image = ImageUpload.find(image_id)
    rescue
      render nothing: true, status: 400
      return
    end

    #todo authorizer for ImageUploads
    if current_user.nil? || current_user.id != image.user.id
      render nothing: true, status: 401
      return
    end

    reclaimed_space_kb = image.src_file_size / 1000.0

    # If the user has access to delete the image, go for it
    result = image.destroy

    # And credit that space back to their bandwidth
    current_user.update(upload_bandwidth_kb: current_user.upload_bandwidth_kb + reclaimed_space_kb)

    render json: { success: result }, status: 200
  end
end
