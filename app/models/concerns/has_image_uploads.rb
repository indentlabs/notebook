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

      result = image_uploads.sample.try(:src, format)
      @random_image_including_private_cache[key] = result

      # If we don't have any uploaded images, we look for saved Basil commissions
      if result.nil? && respond_to?(:basil_commissions)
        result = basil_commissions.where.not(saved_at: nil).includes([:image_attachment]).sample.try(:image)
      end

      # Finally, if we have no image upload, we return the default image for this type
      result = result.presence || header_asset_for(self.class.name)

      result
    end

    def first_public_image(format: :medium)
      public_image_uploads.first.try(:src, format).presence || header_asset_for(self.class.name)
    end

    def random_public_image(format: :medium)
      public_image_uploads.sample.try(:src, format).presence || header_asset_for(self.class.name)
    end

    def header_asset_for(class_name)
      # Since we use this as a fallback image on SEO content (for example, Twitter cards for shared notebook pages),
      # we need to include the full protocol + domain + path to ensure they will display the image. A relative path
      # will not work.
      "https://www.notebook.ai" + ActionController::Base.helpers.asset_url("card-headers/#{class_name.downcase.pluralize}.webp")
    end
  end
end
