class ApplicationIntegration < ApplicationRecord
  belongs_to :user

  def self.icon
    'extension'
  end

  def self.color
    'orange'
  end
end
