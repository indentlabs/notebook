class ContentPage < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :universe

  attr_accessor :favorite, :cached_word_count

  include Authority::Abilities
  self.authorizer_name = 'ContentPageAuthorizer'

  # Returns a single image for use in previews/cards, prioritizing pinned images
  # This method keeps the original behavior of prioritizing pinned images for thumbnails/previews
  def random_image_including_private(format: :small)
    # Always prioritize pinned images first for preview cards
    pinned_image = ImageUpload.where(content_type: self.page_type, content_id: self.id, pinned: true).first
    return pinned_image.src(format) if pinned_image

    pinned_commission = BasilCommission.where(entity_type: self.page_type, entity_id: self.id, pinned: true).where.not(saved_at: nil).includes([:image_attachment]).first
    return pinned_commission.image if pinned_commission

    # Fall back to random images if no pinned images exist
    random_image = ImageUpload.where(content_type: self.page_type, content_id: self.id).sample
    return random_image.src(format) if random_image

    random_commission = BasilCommission.where(entity_type: self.page_type, entity_id: self.id).where.not(saved_at: nil).includes([:image_attachment]).sample
    return random_commission.image if random_commission

    # Use default image as last resort
    ActionController::Base.helpers.asset_path("card-headers/#{self.page_type.downcase.pluralize}.webp")
  end

  def icon
    self.page_type.constantize.icon
  end

  def color
    self.page_type.constantize.color
  end

  def text_color
    self.page_type.constantize.text_color
  end

  def favorite?
    !!favorite
  end

  def view_path
    send("#{self.page_type.downcase}_path", self.id)
  end

  def edit_path
    send("edit_#{self.page_type.downcase}_path", self.id)
  end

  def self.polymorphic_content_fields
    [:id, :name, :favorite, :page_type, :user_id, :cached_word_count, :created_at, :updated_at, :deleted_at, :archived_at, :privacy]
  end
end
