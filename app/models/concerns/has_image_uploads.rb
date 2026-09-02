require 'active_support/concern'

# Gives a page its gallery (uploaded images plus saved Basil images) and one
# way to ask which image represents it: cover_image / cover_image_url.
#
# Views should render through ContentImageHelper#content_image_tag; the URL
# form exists for JSON, meta tags, hidden fields and mailers.
module HasImageUploads
  extend ActiveSupport::Concern

  included do
    has_many :image_uploads, as: :content
    accepts_nested_attributes_for :image_uploads, allow_destroy: true
    # todo: dependent: :destroy_async
    # todo: destroy from s3 on destroy

    # The image that represents this page, as a ContentImage, or nil.
    #
    # Resolution order: an image chosen for +preset+ specifically (cover_for),
    # then the pinned image, then the first (or a random) image with a file.
    # Private uploads are only considered when include_private is true.
    def cover_image(include_private: false, pick: :first, preset: nil)
      @cover_image_cache ||= {}
      preset = preset.to_s if preset.present? && ImagePresets.valid?(preset)
      preset = nil unless preset.is_a?(String)
      key = [include_private, pick, preset]
      return @cover_image_cache[key] if @cover_image_cache.key?(key)

      uploads = image_uploads.to_a
      uploads = uploads.select { |upload| upload.privacy == 'public' } unless include_private
      uploads = uploads.select { |upload| upload.src_file_name.present? }

      basil = if respond_to?(:basil_commissions)
        source = basil_commissions
        if source.respond_to?(:loaded?) && !source.loaded?
          source.where.not(saved_at: nil).includes(image_attachment: :blob).to_a
        else
          source.to_a.select { |commission| commission.saved_at.present? }
        end
      else
        []
      end
      basil = basil.select { |commission| commission.image.attached? }

      chosen = nil
      if preset
        chosen = uploads.select { |upload| upload.cover_for?(preset) }.min_by(&:id) ||
                 basil.select { |commission| commission.cover_for?(preset) }.min_by(&:id)
      end

      chosen ||= uploads.select(&:pinned?).min_by(&:id) ||
                 basil.select(&:pinned?).min_by(&:id)

      if chosen.nil?
        ordered_uploads = uploads.sort_by { |upload| [upload.position || 999_999, upload.id] }
        ordered_basil   = basil.sort_by { |commission| [commission.position || 999_999, commission.id] }
        chosen = if pick == :random
          ordered_uploads.sample || ordered_basil.sample
        else
          ordered_uploads.first || ordered_basil.first
        end
      end

      @cover_image_cache[key] = chosen ? ContentImage.wrap(chosen) : nil
    end

    def cover_image?(include_private: false)
      cover_image(include_private: include_private).present?
    end

    # URL of the cover for +preset+ (see ImagePresets), for places that need a
    # string rather than an <img> tag. Returns the type's placeholder asset
    # path when there is no image, or nil when fallback is false.
    def cover_image_url(preset = :card, include_private: false, pick: :first, size: :full, fallback: true)
      image = cover_image(include_private: include_private, pick: pick, preset: preset)
      url = image && (
        image.preset_url(preset, size: size) ||
        image.url(ImagePresets.fallback_size(preset)) ||
        image.original_url
      )
      return url if url.present?

      fallback ? ActionController::Base.helpers.asset_path(header_asset_for(self.class.name)) : nil
    end

    def clear_cover_image_cache
      @cover_image_cache = nil
      uploads = image_uploads
      uploads.reset if uploads.respond_to?(:loaded?) && uploads.loaded?
      if respond_to?(:basil_commissions)
        commissions = basil_commissions
        commissions.reset if commissions.respond_to?(:loaded?) && commissions.loaded?
      end
    end

    # The generic header image for a content type, as an asset name.
    def header_asset_for(class_name)
      "card-headers/#{class_name.downcase.pluralize}.webp"
    end
  end
end
