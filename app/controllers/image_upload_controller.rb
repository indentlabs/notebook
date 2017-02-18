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

    reclaimed_space = image.src_file_size

    # If the user has access to delete the image, go for it
    image.src.destroy
    result = image.delete

    # And credit that space back to their bandwidth
    #todo

    render json: { success: result }, status: 200
  end
end
