class ContentPage < ApplicationRecord
  belongs_to :user
  belongs_to :universe

  def random_image_including_private(format: :small)
    ImageUpload.where(content_type: self.page_type, content_id: self.id).sample.try(:src, format) || "card-headers/#{self.page_type.downcase.pluralize}.jpg"
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
end
