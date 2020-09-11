class ApplicationIntegration < ApplicationRecord
  belongs_to :user

  has_many :integration_authorizations

  after_create :generate_new_access_token!

  def self.icon
    'extension'
  end

  def self.color
    'orange'
  end

  def generate_new_access_token!
    self.update(application_token: SecureRandom.hex(24))
  end
end
