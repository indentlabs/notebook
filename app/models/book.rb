class Book < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :universe, optional: true

  has_many :book_documents, -> { order(position: :asc) }, dependent: :destroy
  has_many :documents, through: :book_documents

  include HasPrivacy
  include HasPageTags
  include BelongsToUniverse

  include Authority::Abilities
  self.authorizer_name = 'BookAuthorizer'

  enum status: { writing: 0, revising: 1, submitting: 2, published: 3 }

  validates :title, presence: true

  # Display helpers (like Timeline/Document patterns)
  def self.icon
    'menu_book'
  end

  def self.color
    'bg-emerald-500'
  end

  def self.text_color
    'text-emerald-600'
  end

  def self.hex_color
    '#10b981'
  end

  def page_type
    'Book'
  end

  def name
    title
  end

  def archive!
    update(archived_at: Time.current)
  end

  def unarchive!
    update(archived_at: nil)
  end

  def archived?
    archived_at.present?
  end

  scope :unarchived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end
