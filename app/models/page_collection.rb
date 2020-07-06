class PageCollection < ApplicationRecord
  belongs_to :user

  has_many :page_collection_submissions

  def pending_submissions
    page_collection_submissions.where(accepted_at: nil).order('submitted_at ASC')
  end

  def accepted_submissions
    page_collection_submissions.where.not(accepted_at: nil).order('accepted_at DESC')
  end

  def contributors
    User.where(id: accepted_submissions.pluck(:user_id) - [user.id])
  end

  serialize :page_types, Array

  def self.color
    'brown'
  end

  def self.icon
    'layers'
  end
end
