class ContentPage < ApplicationRecord
  belongs_to :user
  belongs_to :universe

  def random_image_including_private(format: :small)
    ImageUpload.where(content_type: self.page_type, content_id: self.id).sample.try(:src, format) || "card-headers/#{self.page_type.downcase.pluralize}.jpg"
  end
end
