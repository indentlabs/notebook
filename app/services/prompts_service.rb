class PromptsService < Service
  def self.image_categories_for(user)
    Rails.application.config.content_types[:all].map(&:name)
  end
end
