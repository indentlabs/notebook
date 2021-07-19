class PageCollection < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user

  has_many :page_collection_submissions, dependent: :destroy

  has_many :page_collection_followings, dependent: :destroy
  has_many :followers, through: :page_collection_followings, source: :user

  has_many :page_collection_reports, dependent: :destroy

  has_one_attached :header_image, dependent: :destroy
  validates :header_image, attached: false,
    content_type: {
      in: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'],
      message: 'must be a PNG, JPG, JPEG, or GIF'
    },
    dimension: { 
      width: { max: 2000 },
      height: { max: 2000 }, 
      message: 'must be smaller than 2000x2000 pixels'
    },
    size: { 
      less_than: 1024.kilobytes, 
      message: "can't be larger than 1MB"
    }
  
  validates :title, presence: true

  include Authority::Abilities
  self.authorizer_name = 'CollectionAuthorizer'

  def pending_submissions
    page_collection_submissions.where(accepted_at: nil).order('submitted_at ASC')
  end

  def accepted_submissions
    page_collection_submissions.where.not(accepted_at: nil).order('accepted_at DESC')
  end

  def contributors
    User.where(id: accepted_submissions.pluck(:user_id) - [user.id])
  end

  def random_public_image
    return cover_image if cover_image.present?

    if header_image.attachment.present?
      return header_image
    end

    # If all else fails, fall back on default header
    "card-headers/#{self.class.name.downcase.pluralize}.jpg"
  end

  def first_public_image
    random_public_image
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

  def self.text_color
    'brown-text'
  end

  def self.hex_color
    '#795548'
  end

  def self.icon
    'layers'
  end
end
