class PageCollection < ApplicationRecord
  belongs_to :user

  has_many :page_collection_submissions
  has_many :page_collection_followings
  has_many :page_collection_reports

  def pending_submissions
    page_collection_submissions.where(accepted_at: nil).order('submitted_at ASC')
  end

  def accepted_submissions
    page_collection_submissions.where.not(accepted_at: nil).order('accepted_at DESC')
  end

  def contributors
    User.where(id: accepted_submissions.pluck(:user_id) - [user.id])
  end

  # Some quick aliases so we can treat this like a content page in streams:
  def random_public_image
    cover_image
  end
  def name
    title
  end

  def followed_by?(user)
    return false if user.nil?
    
    user.page_collection_followings.find_by(page_collection_id: self.id).present?
  end

  serialize :page_types, Array

  def self.color
    'brown'
  end

  def self.icon
    'layers'
  end
end
