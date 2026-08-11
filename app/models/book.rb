class Book < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :universe, optional: true

  has_many :book_documents, -> { order(position: :asc) }, dependent: :destroy
  has_many :documents, through: :book_documents
  has_many :word_count_updates, as: :entity

  include HasPrivacy
  include HasPageTags
  include BelongsToUniverse
  include HasImageUploads

  include Authority::Abilities
  self.authorizer_name = 'BookAuthorizer'

  enum status: { writing: 0, revising: 1, submitting: 2, published: 3 }

  validates :name, presence: true

  # A book is effectively public when anyone can view it: either its own
  # privacy is public, or it belongs to a public universe (which makes the
  # book readable per BookAuthorizer).
  def effectively_public?
    privacy == 'public' || universe.try(:privacy) == 'public'
  end

  # Track word count changes for description and blurb fields
  WORD_COUNT_TRACKED_FIELDS = %w[description blurb].freeze

  after_commit :enqueue_word_count_update, if: :word_count_fields_changed?

  def word_count_fields_changed?
    (saved_changes.keys & WORD_COUNT_TRACKED_FIELDS).any?
  end

  def enqueue_word_count_update
    CacheBookWordCountJob.perform_later(self.id)
  rescue StandardError => e
    Rails.logger.error("Failed to enqueue CacheBookWordCountJob: #{e.message}")
  end

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

  # Instance methods that delegate to class methods
  # Needed for views that call book.color, book.icon, etc.
  def color
    Book.color
  end

  def icon
    Book.icon
  end

  def text_color
    Book.text_color
  end

  def hex_color
    Book.hex_color
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

  private
end
