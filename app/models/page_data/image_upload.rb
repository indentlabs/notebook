class ImageUpload < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :content, polymorphic: true

  # Add scopes for image ordering
  scope :pinned, -> { where(pinned: true) }
  scope :ordered, -> { order(:position) }

  # This is the old way we uploaded files -- now we're transitioning to ActiveStorage's has_one_attached
  has_attached_file :src,
    path: 'content/uploads/:style/:filename',
    styles: {
      thumb:  '100x100>',
      small:  '190x190#',
      square: '280x280#',
      medium: '300x300>',
      large:  '600x600>',
      hero:   '800x800>'
    },
    filename_cleaner: -> (filename) {
      [
        SecureRandom.uuid,
        File.extname(filename).downcase
      ].join
    },
    s3_protocol: 'https',
    url: '/system/:class/:attachment/:id_partition/:style/:filename'
  # has_one_attached :upload

  validates_attachment_content_type :src, content_type: /\Aimage\/.*\Z/
  # TODO add size validation

  before_destroy :delete_s3_image

  # Point content IDs to generalized content_id for cocoon
  alias_attribute 'character_id', :content_id
  #alias_attribute ...

  # Use acts_as_list for ordering images
  acts_as_list scope: [:content_type, :content_id]

  # Add callback to ensure only one pinned image per content
  before_save :ensure_single_pinned_image, if: -> { pinned_changed? && pinned? }

  def delete_s3_image
    # todo: put this in a task for faster delete response times
    src.destroy
  end

  private

  # Ensures only one image can be pinned per content item
  def ensure_single_pinned_image
    ImageUpload.where(content_type: content_type, content_id: content_id, pinned: true)
              .where.not(id: id)
              .update_all(pinned: false)
  end
end
