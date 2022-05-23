require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    # todo: dependent: :destroy_async
    # todo: destroy from s3 on destroy

    def public_image_uploads
      self.image_uploads.where(privacy: 'public').presence || [header_asset_for(self.class.name)]
    end

    def private_image_uploads
      self.image.uploads.where(privacy: 'private').presence || [header_asset_for(self.class.name)]
    end

    def random_image_including_private(format: :medium)
      @random_image_including_private_cache ||= {}
      key = self.class.name + self.id.to_s
      return @random_image_including_private_cache[key] if @random_image_including_private_cache.key?(key)

      result = image_uploads.sample.try(:src, format).presence || header_asset_for(self.class.name)
      @random_image_including_private_cache[key] = result

      result
    end

    def first_public_image(format: :medium)
      public_image_uploads.first.try(:src, format).presence || header_asset_for(self.class.name)
    end

    def random_public_image(format: :medium)
      public_image_uploads.sample.try(:src, format).presence || header_asset_for(self.class.name)
    end

    def header_asset_for(class_name)
      ActionController::Base.helpers.asset_path("card-headers/#{class_name.downcase.pluralize}.webp")
    end
  end
end
