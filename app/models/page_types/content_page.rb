class ContentPage < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :universe

  attr_accessor :favorite, :cached_word_count

  include Authority::Abilities
  self.authorizer_name = 'ContentPageAuthorizer'

  def random_image_including_private(format: :small)
    ImageUpload.where(content_type: self.page_type, content_id: self.id).sample.try(:src, format) \
    || BasilCommission.where(entity_type: self.page_type, entity_id: self.id).where.not(saved_at: nil).sample.try(:image) \
    || ActionController::Base.helpers.asset_path("card-headers/#{self.page_type.downcase.pluralize}.webp")
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
