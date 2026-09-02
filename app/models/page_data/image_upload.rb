class ImageUpload < ApplicationRecord
  include Authority::Abilities
  include HasImageFraming
  include HasCoverRoles

  belongs_to :user, optional: true
  belongs_to :content, polymorphic: true

  # Inherit user_id from parent content when created through nested attributes
  before_validation :inherit_user_id, on: :create
  
  def inherit_user_id
    self.user_id ||= content&.user_id
  end

  # Add scopes for image ordering
  scope :pinned, -> { where(pinned: true) }
  scope :ordered, -> { order(:position) }

  # This is the old way we uploaded files -- now we're transitioning to ActiveStorage's has_one_attached
  # Derivatives regenerated when the framing changes (see ImagePresets) plus
  # the large WebP used by the lightbox and the editor instead of the original.
  FRAMED_STYLES = ImagePresets.style_names.freeze
  XLARGE_STYLE  = ImagePresets.webp_style('1600x1600>', convert_options: '-quality 85 -strip').freeze

  has_attached_file :src,
    **(Rails.env.production? ? { path: 'content/uploads/:style/:filename', s3_headers: { 'Cache-Control' => 'public, max-age=31536000' } } : {}),
    styles: {
      # Legacy JPEG/PNG sizes, still used as fallbacks and by RSS readers
      thumb:  '100x100>',
      small:  '190x190#',
      medium: '300x300>',
      large:  '600x600>',
      hero:   '800x800>',
      xlarge: XLARGE_STYLE,
      # Shape derivatives cut by the gallery editor's framing (lib/paperclip_processors/cropper.rb)
      **ImagePresets.paperclip_styles
    },
    filename_cleaner: -> (filename) {
      [
        SecureRandom.uuid,
        File.extname(filename).downcase
      ].join
    },
    s3_protocol: 'https'
  # has_one_attached :upload

  # Remember the original's pixel size so crops can be validated and the
  # editor can lay out the image before it has loaded.
  before_post_process :capture_dimensions
  before_save :mark_crops_generated, if: :will_save_change_to_src_file_name?
  after_commit :regenerate_crops_later, on: :update, if: :framing_changed?

  def capture_dimensions
    file = src.queued_for_write[:original]
    return true if file.nil?

    geometry = Paperclip::Geometry.from_file(file)
    geometry.auto_orient # match what browsers (and the editor) display
    self.width  = geometry.width.to_i
    self.height = geometry.height.to_i
    true
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError, Paperclip::Errors::CommandNotFoundError, Errno::ENOENT
    true
  end

  # Paperclip cuts the shape styles synchronously when a file is stored, so
  # a freshly uploaded image already has its derivatives.
  def mark_crops_generated
    self.crops_generated_at = Time.current if src_file_name.present?
  end

  def regenerate_crops_later
    GenerateImageCropsJob.perform_later('ImageUpload', id)
  end

  validates_attachment_content_type :src,
    content_type: /\Aimage\/.*\Z/,
    message: "must be an image file (like a jpg, png, gif, or webp)"
  # TODO add size validation

  before_destroy :delete_s3_image

  # Point content IDs to generalized content_id for cocoon
  alias_attribute 'character_id', :content_id
  #alias_attribute ...

  # Use acts_as_list for ordering images
  acts_as_list scope: [:content_type, :content_id]

  # Note: Pin unpinning logic is handled in the controller to prevent database locking issues

  def delete_s3_image
    # todo: put this in a task for faster delete response times
    src.destroy
  end

  private
end
