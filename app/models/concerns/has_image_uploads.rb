require 'active_support/concern'

module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    accepts_nested_attributes_for :image_uploads, allow_destroy: true
    # todo: dependent: :destroy_async
    # todo: destroy from s3 on destroy

    def primary_image
      # self.image_uploads.find_by(primary: true) || self.image_uploads.first
      self.image_uploads.first.presence || [header_asset_for(self.class.name)]
    end

    def extract_image_url(upload, format = :medium)
      return nil unless upload
      
      # Fast Paperclip check: ensure an underlying file is recorded in the DB
      # before asking for a URL, dodging the default 'missing.png' return.
      if upload.respond_to?(:src_file_name) && upload.src_file_name.blank?
        return nil
      end

      # Future-proofing for upcoming ActiveStorage transition
      if upload.respond_to?(:upload) && upload.upload.respond_to?(:attached?) && !upload.upload.attached?
        return nil
      end

      url = upload.try(:src, format).to_s
      return nil if url.blank? || url.include?('missing.png')
      url
    end

    def public_image_uploads
      uploads = if image_uploads.loaded?
        image_uploads.select { |upload| upload.privacy == 'public' }
      else
        self.image_uploads.where(privacy: 'public')
      end
      uploads.presence || [header_asset_for(self.class.name)]
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
        result = extract_image_url(image_uploads.sample, format)
        
        # If we don't have any uploaded images, we look for saved Basil commissions
        if result.nil? && respond_to?(:basil_commissions)
          basil_image = if basil_commissions.loaded?
            basil_commissions.select { |commission| commission.saved_at.present? }.sample.try(:image)
          else
            basil_commissions.where.not(saved_at: nil).includes([:image_attachment]).sample.try(:image)
          end
          # Handle Active Storage attachments properly
          if basil_image.present? && basil_image.respond_to?(:url)
            begin
              result = basil_image.url
            rescue
              result = nil
            end
          end
        end
      end

      # Cache the result (only cache non-nil results to avoid issues)
      @random_image_including_private_cache[key] = result if result.present?

      # Finally, if we have no valid image URL, return the default image for this type
      result.presence || header_asset_for(self.class.name)
    end

    def first_public_image(format = :medium)
      # First check for pinned public images
      pinned = pinned_public_image(format: format)
      return pinned if pinned.present?
      
      # Fall back to first public image
      extract_image_url(public_image_uploads.first, format).presence || header_asset_for(self.class.name)
    end

    def random_public_image(format = :medium)
      # First check for pinned public images
      pinned = pinned_public_image(format: format)
      return pinned if pinned.present?
      
      # Fall back to random public image
      extract_image_url(public_image_uploads.sample, format).presence || header_asset_for(self.class.name)
    end

    def custom_public_thumbnail_url(format: :medium)
      url = first_public_image(format)
      fallback_url = header_asset_for(self.class.name)
      url == fallback_url ? nil : url
    end
    
    # Returns the pinned image upload (or nil if none pinned)
    def pinned_image_upload(format = :medium)
      # First check standard image uploads
      pinned_upload = if image_uploads.loaded?
        image_uploads.select(&:pinned?).min_by(&:id)
      else
        image_uploads.pinned.first
      end
      if pinned_upload.present?
        url = extract_image_url(pinned_upload, format)
        return url if url.present?
      end

      # Then check basil commissions
      if respond_to?(:basil_commissions)
        pinned_commission = if basil_commissions.loaded?
          basil_commissions.select { |commission| commission.pinned? && commission.saved_at.present? }.min_by(&:id)
        else
          basil_commissions.pinned.where.not(saved_at: nil).includes([:image_attachment]).first
        end
        if pinned_commission.present?
          basil_image = pinned_commission.try(:image)
          # Handle Active Storage attachments properly
          if basil_image.present? && basil_image.respond_to?(:url)
            begin
              return basil_image.url
            rescue
              return nil
            end
          end
        end
      end
      
      nil
    end
    
    # Returns the pinned public image (or nil if none pinned)
    def pinned_public_image(format = :medium)
      pinned_upload = if image_uploads.loaded?
        image_uploads.select { |upload| upload.pinned? && upload.privacy == 'public' }.min_by(&:id)
      else
        image_uploads.pinned.where(privacy: 'public').first
      end
      if pinned_upload.present?
        url = extract_image_url(pinned_upload, format)
        return url if url.present?
      end

      if respond_to?(:basil_commissions)
        pinned_commission = if basil_commissions.loaded?
          basil_commissions.select { |commission| commission.pinned? && commission.saved_at.present? }.min_by(&:id)
        else
          basil_commissions.pinned.where.not(saved_at: nil).includes([:image_attachment]).first
        end
        if pinned_commission.present?
          basil_image = pinned_commission.try(:image)
          # Handle Active Storage attachments properly
          if basil_image.present? && basil_image.respond_to?(:url)
            begin
              return basil_image.url
            rescue
              return nil
            end
          end
        end
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

    # Returns a custom user image (pinned, uploaded, or basil generated)
    # but explicitly returns nil instead of the generic header placeholder.
    # Useful for UI elements that should fallback to an icon instead of a generic header image.
    def custom_thumbnail_url(format: :medium)
      url = pinned_or_random_image_including_private(format: format)
      url == header_asset_for(self.class.name) ? nil : url
    end

    def header_asset_for(class_name)
      "card-headers/#{class_name.downcase.pluralize}.webp"
    end
  end
end
