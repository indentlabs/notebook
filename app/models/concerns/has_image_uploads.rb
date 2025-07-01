require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    # todo: dependent: :destroy_async
    # todo: destroy from s3 on destroy

    def primary_image
      # self.image_uploads.find_by(primary: true) || self.image_uploads.first
      self.image_uploads.first.presence || [header_asset_for(self.class.name)]
    end

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

      # First check for pinned images (prioritize pinned images over random ones)
      result = pinned_image_upload(format)
      
      # If no pinned image, fall back to random selection
      if result.nil?
        result = image_uploads.sample.try(:src, format)
        
        # If we don't have any uploaded images, we look for saved Basil commissions
        if result.nil? && respond_to?(:basil_commissions)
          result = basil_commissions.where.not(saved_at: nil).includes([:image_attachment]).sample.try(:image)
        end
      end

      # Cache the result
      @random_image_including_private_cache[key] = result

      # Finally, if we have no image upload, we return the default image for this type
      result = result.presence || header_asset_for(self.class.name)

      result
    end

    def first_public_image(format = :medium)
      # First check for pinned public images
      pinned = pinned_public_image(format: format)
      return pinned if pinned.present?
      
      # Fall back to first public image
      public_image_uploads.first.try(:src, format).presence || header_asset_for(self.class.name)
    end

    def random_public_image(format = :medium)
      # First check for pinned public images
      pinned = pinned_public_image(format: format)
      return pinned if pinned.present?
      
      # Fall back to random public image
      public_image_uploads.sample.try(:src, format).presence || header_asset_for(self.class.name)
    end
    
    # Returns the pinned image upload (or nil if none pinned)
    def pinned_image_upload(format = :medium)
      # First check standard image uploads
      pinned_upload = image_uploads.pinned.first
      return pinned_upload.try(:src, format) if pinned_upload.present?
      
      # Then check basil commissions
      if respond_to?(:basil_commissions)
        pinned_commission = basil_commissions.pinned.where.not(saved_at: nil).includes([:image_attachment]).first
        return pinned_commission.try(:image) if pinned_commission.present?
      end
      
      nil
    end
    
    # Returns the pinned public image (or nil if none pinned)
    def pinned_public_image(format = :medium)
      pinned_upload = image_uploads.pinned.where(privacy: 'public').first
      return pinned_upload.try(:src, format) if pinned_upload.present?
      
      if respond_to?(:basil_commissions)
        pinned_commission = basil_commissions.pinned.where.not(saved_at: nil).includes([:image_attachment]).first
        return pinned_commission.try(:image) if pinned_commission.present?
      end
      
      nil
    end

    def pinned_or_random_image_including_private(format: :medium)
      # First check for pinned images
      pinned = pinned_image_upload(format)
      return pinned if pinned.present?

      # If no pinned image, fall back to random selection
      random_image_including_private(format: format)
    end

    def header_asset_for(class_name)
      # Since we use this as a fallback image on SEO content (for example, Twitter cards for shared notebook pages),
      # we need to include the full protocol + domain + path to ensure they will display the image. A relative path
      # will not work.
      # 
      # For direct view rendering, we use the relative asset path which works better with image_tag
      Rails.env.production? ? 
        "https://www.notebook.ai" + ActionController::Base.helpers.asset_url("card-headers/#{class_name.downcase.pluralize}.webp") :
        ActionController::Base.helpers.asset_path("card-headers/#{class_name.downcase.pluralize}.webp")
    end
  end
end
