class ImageUpload < ApplicationRecord
  belongs_to :user
  belongs_to :content, polymorphic: true

  has_attached_file :src,
    path: 'content/uploads/:style/:filename',
    styles: {
      thumb: '100x100>',
      small: '190x190#',
      square: '280x280#',
      medium: '300x300>',
      large: '600x600>',
      hero: '800x800>'
    },
    filename_cleaner: -> (filename) {
      [
        SecureRandom.uuid,
        File.extname(filename).downcase
      ].join
    }

  validates_attachment_content_type :src, content_type: /\Aimage\/.*\Z/

  before_destroy :delete_s3_image

  # Point content IDs to generalized content_id for cocoon
  alias_attribute 'character_id', :content_id
  #alias_attribute ...

  def delete_s3_image
    # todo: put this in a task for faster delete response times
    src.destroy
  end
end
