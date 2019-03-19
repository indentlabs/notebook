require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    # todo: dependent: :destroy
    # todo: destroy from s3 on destroy

    def image_uploads
      ImageUpload.where(
        content_type: self.class.name,
        content_id: self.id
      )
    end

    def public_image_uploads
      self.image_uploads.where(privacy: 'public')
    end

    def private_image_uploads
      self.image.uploads.where(privacy: 'private')
    end
  end
end
