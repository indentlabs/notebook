require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    # todo: dependent: :destroy_async
    # todo: destroy from s3 on destroy

    def public_image_uploads
      self.image_uploads.where(privacy: 'public').presence || ["card-headers/#{self.class.name.downcase.pluralize}.webp"]
    end

    def private_image_uploads
      self.image.uploads.where(privacy: 'private').presence || ["card-headers/#{self.class.name.downcase.pluralize}.webp"]
    end

    def random_image_including_private(format: :medium)
      image_uploads.sample.try(:src, format).presence || "card-headers/#{self.class.name.downcase.pluralize}.webp"
    end

    def first_public_image(format: :medium)
      public_image_uploads.first.try(:src, format).presence || "card-headers/#{self.class.name.downcase.pluralize}.webp"
    end

    def random_public_image(format: :medium)
      public_image_uploads.sample.try(:src, format).presence || "card-headers/#{self.class.name.downcase.pluralize}.webp"
    end
  end
end
