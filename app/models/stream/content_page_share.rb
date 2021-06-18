class ContentPageShare < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user
  belongs_to :content_page,           polymorphic: true, optional: true
  belongs_to :secondary_content_page, polymorphic: true, optional: true

  has_many :share_comments,                dependent: :destroy
  has_many :content_page_share_followings, dependent: :destroy
  has_many :content_page_share_reports,    dependent: :destroy

  after_create do
    # Subscribe the OP to new notifications whenever a post is created
    user.content_page_share_followings.create({content_page_share: self})
  end

  def followed_by?(user)
    return false if user.nil?
    
    user.content_page_share_followings.find_by(content_page_share_id: self.id).present?
  end

  def subscribe(user)
    user.content_page_share_followings.find_or_create_by(content_page_share_id: self.id)
  end

  def self.color
    'text-lighten-3 purple'
  end

  def self.hex_color
    '#CE93D8'
  end

  def self.icon
    'stream'
  end
end
