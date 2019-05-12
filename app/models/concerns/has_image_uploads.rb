require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    # todo: dependent: :destroy
    # todo: destroy from s3 on destroy

    def public_image_uploads
      self.image_uploads.where(privacy: 'public')
    end

    def private_image_uploads
      self.image.uploads.where(privacy: 'private')
    end

    def random_public_image(format: :medium)
      public_image_uploads.sample.try(:src, format).presence || "card-headers/#{self.class.name.downcase.pluralize}.jpg"
    end
  end
end
