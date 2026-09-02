# Stores one uploaded image against a content page, charging the uploader's
# bandwidth quota and refunding it if the upload fails.
#
#   result = ImageUploadService.upload(user: current_user, content: character, file: params[:src])
#   result.success?  # => true / false
#   result.image     # => the persisted ImageUpload on success
#   result.error     # => a user-facing sentence on failure
class ImageUploadService
  Result = Struct.new(:image, :error, :charged_kb, keyword_init: true) do
    def success?
      error.nil? && image.present? && image.persisted?
    end
  end

  def self.upload(user:, content:, file:, privacy: 'public')
    new(user: user, content: content, file: file, privacy: privacy).call
  end

  def initialize(user:, content:, file:, privacy: 'public')
    @user    = user
    @content = content
    @file    = file
    @privacy = %w[public private].include?(privacy.to_s) ? privacy.to_s : 'public'
  end

  def call
    return Result.new(error: 'No file was sent.') if @file.blank?

    size_kb = file_size_kb

    if @user.upload_bandwidth_kb < size_kb
      return Result.new(
        error: "#{filename} couldn't be uploaded because you don't have enough upload bandwidth left. Upgrade to Premium or delete some existing images for more.",
        charged_kb: 0
      )
    end

    image = nil

    # Charge and store together so an exception mid-upload cannot leave the
    # quota charged for an image that was never saved.
    ImageUpload.transaction do
      @user.update(upload_bandwidth_kb: @user.upload_bandwidth_kb - size_kb)

      image = ImageUpload.create(
        user:         @user,
        content_type: @content.class.name,
        content_id:   @content.id,
        src:          @file,
        privacy:      @privacy
      )
    end

    if image.persisted?
      Result.new(image: image, charged_kb: size_kb)
    else
      # Nothing was stored, so hand the bandwidth we just charged back over.
      @user.update(upload_bandwidth_kb: @user.upload_bandwidth_kb + size_kb)
      reason = image.errors[:src].first.presence || "couldn't be uploaded"
      Result.new(error: "#{filename} #{reason}.", charged_kb: 0)
    end
  end

  private

  def filename
    ERB::Util.html_escape(@file.try(:original_filename).presence || 'Your image')
  end

  def file_size_kb
    bytes = if @file.respond_to?(:size) && @file.size
      @file.size
    elsif @file.respond_to?(:tempfile)
      File.size(@file.tempfile.path)
    else
      File.size(@file.path)
    end

    # The quota column is an integer number of kilobytes, so charge whole
    # kilobytes (rounded up) and refund exactly the same amount on failure.
    (bytes / 1000.0).ceil
  end
end
