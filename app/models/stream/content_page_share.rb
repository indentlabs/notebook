class ContentPageShare < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user
  belongs_to :content_page,           polymorphic: true, optional: true
  belongs_to :secondary_content_page, polymorphic: true, optional: true

  has_many :share_comments,                dependent: :destroy
  has_many :content_page_share_followings, dependent: :destroy
  has_many :content_page_share_reports,    dependent: :destroy

  validate :pages_are_not_password_protected, on: :create

  after_create do
    # Subscribe the OP to new notifications whenever a post is created
    user.content_page_share_followings.create({content_page_share: self})
  end

  # Shares show a page's title and an excerpt to everyone in the stream
  def pages_are_not_password_protected
    return unless [content_page, secondary_content_page].any? { |page| page.try(:password_protected?) }

    errors.add(:base, "Password protected documents can't be shared. Change its privacy setting first.")
  end

  # Human-readable label for the shared page's type, e.g. "character" or
  # "topic" (rather than raw class names like "Thredded::Topic").
  def content_page_type_label
    self.class.page_type_label(content_page)
  end

  def secondary_content_page_type_label
    self.class.page_type_label(secondary_content_page)
  end

  def self.page_type_label(page)
    return 'page' if page.nil?
    return page.class.content_name if page.class.respond_to?(:content_name)

    page.class.name.demodulize.underscore.humanize.downcase
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

  def self.text_color
    'text-lighten-3 purple-text'
  end

  def self.hex_color
    '#CE93D8'
  end

  def self.icon
    'ballot'
  end
end
