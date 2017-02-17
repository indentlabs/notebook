class ImageUpload < ActiveRecord::Base
  belongs_to :user

  has_attached_file :src,
    path: 'content/uploads/:style/:filename',
    styles: {
      thumb: '100x100>',
      square: '280x280#',
      medium: '300x300>'
    },
    filename_cleaner: -> (filename) {
      [
        SecureRandom.uuid,
        File.extname(filename).downcase
      ].join
    }

  validates_attachment_content_type :src, content_type: /\Aimage\/.*\Z/

  # Point content IDs to generalized content_id for cocoon
  alias_attribute 'character_id', :content_id
  #alias_attribute ...
end
