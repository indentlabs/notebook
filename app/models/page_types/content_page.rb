class ContentPage < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :universe

  attr_accessor :favorite

  include Authority::Abilities
  self.authorizer_name = 'ContentPageAuthorizer'

  # TODO: this is gonna be an N+1 query any time we display a list of ContentPages with images
  def random_image_including_private(format: :small)
    ImageUpload.where(content_type: self.page_type, content_id: self.id).sample.try(:src, format) || ActionController::Base.helpers.asset_path("card-headers/#{self.page_type.downcase.pluralize}.webp")
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
    [:id, :name, :favorite, :page_type, :user_id, :created_at, :updated_at, :deleted_at, :archived_at, :privacy]
  end
end
