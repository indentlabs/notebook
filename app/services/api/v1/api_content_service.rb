class Api::V1::ApiContentService < Service
  # e.g. content(api_key: 'test-key', content_type: 'characters')
  def self.content(api_key:, content_type:)
    user = User.from_api_key(api_key)

    return "Error: Invalid API Key"      if user.nil?
    return "Error: Invalid content type" unless valid_content_type?(content_type)

    # todo we need to serialize attributes instead of natural model columns
    user.send(content_type.downcase.pluralize).as_json
  end

  # todo create
  def self.create(api_key:, content_type:, attributes_hash:)
  end

  # todo update
  def self.update(api_key:, content_type:, content_id:, attributes_hash:)
  end

  # todo delete
  def self.delete(api_key:, content_type:, content_id:)
  end

  # todo list: permission to create
  # todo list: page turned on
  # todo link to anonymous account from app?

  private

  def self.valid_content_type?(content_type)
    Rails.application.config.content_types[:all].map(&:name).include?(content_type.titleize)
  end

end
