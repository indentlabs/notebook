class ImageUploadController < ApplicationController
  before_action :authenticate_user!
  before_action :find_image, only: [:update, :delete]
  before_action :require_manage_permission, only: [:update, :delete]

  # POST /image_uploads
  # JSON endpoint used by the gallery's drop-zone uploader. Accepts one file
  # per request and responds with the rendered gallery card for the new image.
  def create
    content = ContentImage.resolve_content(params[:content_type], params[:content_id])
    if content.nil?
      return render json: { error: 'Page not found' }, status: :not_found
    end

    unless ContentImageAuthorization.can_manage?(current_user, content)
      return render json: { error: 'You do not have permission to add images to this page' }, status: :forbidden
    end

    file = params[:src].presence || params.dig(:image_upload, :src)
    result = ImageUploadService.upload(
      user:    current_user,
      content: content,
      file:    file,
      privacy: params[:privacy].presence || 'public'
    )

    remaining_kb = current_user.reload.upload_bandwidth_kb

    if result.success?
      image = ContentImage.wrap(result.image)
      html  = render_to_string(
        partial: 'content/edit/gallery/card',
        formats: [:html],
        locals:  { image: image, content: content }
      )

      render json: {
        success:      true,
        image:        image.as_json,
        html:         html,
        remaining_kb: remaining_kb
      }, status: :created
    else
      render json: { error: result.error, remaining_kb: remaining_kb }, status: :unprocessable_entity
    end
  end

  # DELETE /delete/image/:id
  def delete
    reclaimed_space_kb = (@image.src_file_size || 0) / 1000.0
    # Credit the quota back to whoever paid for the upload.
    owner = @image.user || @image.content&.user

    result = @image.destroy

    if result && owner
      owner.update(upload_bandwidth_kb: owner.upload_bandwidth_kb + reclaimed_space_kb)
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'Image successfully deleted.' }
      format.all do
        render json: {
          success:      result ? true : false,
          reclaimed_kb: reclaimed_space_kb.round(2),
          remaining_kb: current_user.reload.upload_bandwidth_kb
        }, status: 200
      end
    end
  end

  # PATCH /image_uploads/:id
  def update
    if @image.update(image_upload_params)
      render json: {
        success: true,
        notes:   @image.notes,
        image:   ContentImage.wrap(@image).as_json
      }, status: 200
    else
      render json: { error: @image.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def find_image
    @image = ImageUpload.find_by(id: params[:id])
    return if @image.present?

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'Image not found.' }
      format.all { render json: { error: 'Image not found' }, status: :not_found }
    end
  end

  def require_manage_permission
    return if @image.updatable_by?(current_user)

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'Unauthorized.' }
      format.all { render json: { error: 'Unauthorized' }, status: :forbidden }
    end
  end

  def image_upload_params
    params.require(:image_upload).permit(:notes, :privacy)
  end
end
