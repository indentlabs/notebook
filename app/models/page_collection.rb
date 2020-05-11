class PageCollection < ApplicationRecord
  belongs_to :user

  has_many :page_collection_submissions

  def pending_submissions
    page_collection_submissions.where(accepted_at: nil)
  end

  def accepted_submissions
    page_collection_submissions.where.not(accepted_at: nil)
  end

  def contributors
    User.where(id: accepted_submissions.pluck(:user_id))
  end

  serialize :page_types, Array

  def self.color
    'brown'
  end

  def self.icon
    'layers'
  end
end
