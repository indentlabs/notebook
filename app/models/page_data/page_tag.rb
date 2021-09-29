class PageTag < ApplicationRecord
  belongs_to :page, polymorphic: true
  belongs_to :user

  # Delimiter to be used wherever we want to allow submitting multiple tags in a single string
  SUBMISSION_DELIMITER = ',,,|||,,,'

  def to_s
    self.tag
  end

  def self.icon
    'label'
  end
end
