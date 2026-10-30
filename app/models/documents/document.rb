class Document < ApplicationRecord
  include Rails.application.routes.url_helpers
  acts_as_paranoid

  belongs_to :user,     optional: true

  has_many :document_analysis,   dependent: :destroy
  has_many :document_entities,   through: :document_analysis
  has_many :document_concepts,   through: :document_analysis
  has_many :document_categories, through: :document_analysis

  has_many :document_revisions, dependent: :destroy
  # After commit, so a slow or failing enqueue can't hold the row lock or roll back the save itself
  after_update_commit :save_document_revision!

  has_many :book_documents, dependent: :destroy
  has_many :books, through: :book_documents

  include HasParseableText
  include HasPartsOfSpeech
  include HasImageUploads
  include HasPageTags
  include BelongsToUniverse
  include HasPrivacy

  PRIVACY_LABELS = {
    'private'  => 'Private',
    'public'   => 'Public',
    'password' => 'Password protected'
  }.freeze

  # bcrypt ignores everything past 72 bytes
  PASSWORD_LENGTH = 5..72

  has_secure_password :document_password, validations: false

  # Only checked when these change, so a row with an old or unexpected value can still be autosaved.
  validates :privacy, inclusion: { in: PRIVACY_LABELS.keys }, allow_blank: true, if: :will_save_change_to_privacy?
  validates :document_password_digest, presence: true, if: :password_protected?
  validates :document_password,
            length: { in: PASSWORD_LENGTH, too_short: 'must be at least %{count} characters', too_long: 'must be at most %{count} characters' },
            if: -> { @changing_password_protection && password_protected? }
  validate :password_protection_changed_explicitly, if: -> { will_save_change_to_privacy? || will_save_change_to_document_password_digest? }

  belongs_to :folder, optional: true
  validate :folder_belongs_to_owner, if: :will_save_change_to_folder_id?

  # Status enum for document workflow tracking
  enum status: {
    idea: 0,
    draft: 1,
    writing: 2,
    revising: 3,
    editing: 4,
    submitting: 5,
    published: 6,
    complete: 7
  }

  def folder_belongs_to_owner
    errors.add(:folder, "isn't one of yours") if folder && folder.user_id != user_id
  end

  # Returns status options for select dropdowns: [['Display Label', 'value'], ...]
  def self.status_options
    [
      ['Idea', 'idea'],
      ['Draft', 'draft'],
      ['Writing', 'writing'],
      ['Revising', 'revising'],
      ['Editing', 'editing'],
      ['Submitting', 'submitting'],
      ['Published', 'published'],
      ['Complete', 'complete']
    ]
  end

  # TODO: include IsContentPage ?

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  attr_accessor :tagged_text

  # Duplicated from is_content_page since we don't include that here yet
  has_many :word_count_updates, as: :entity
  def latest_word_count_cache
    word_count_updates.order('for_date DESC').limit(1).first.try(:word_count) ||  0
  end

  KEYS_TO_TRIGGER_REVISION_ON_CHANGE = %w(title body synopsis notes_text)

  # Books (by the same author) that expose this document to the public:
  # either the book itself is public, or the book is in a public universe.
  # Scoped to the document owner's own books so another user's book can
  # never publish this document.
  PUBLIC_BOOK_CONDITION = <<~SQL.squish.freeze
    books.privacy = 'public'
    OR books.universe_id IN (SELECT universes.id FROM universes WHERE universes.privacy = 'public')
  SQL

  def containing_public_books
    books.where(user_id: user_id).where(PUBLIC_BOOK_CONDITION)
  end

  # Mirrors the universe convention: a public container makes its contents
  # readable. Purely additive and computed at read time, so toggling the
  # book (or removing the document from it) instantly reverts visibility.
  def readable_via_public_book?
    return false if new_record? || password_protected?

    containing_public_books.exists?
  end

  # Overrides HasPrivacy#public_content? to reflect *effective* visibility,
  # including exposure through a public book.
  def public_content?
    return false if password_protected?

    universe_is_public = universe.present? && universe.public_content?
    privacy == 'public' || universe_is_public || readable_via_public_book?
  end

  def password_protected?
    privacy == 'password'
  end

  def privacy_label
    PRIVACY_LABELS.fetch(privacy, PRIVACY_LABELS['private'])
  end

  def privacy_icon
    { 'public' => 'public', 'password' => 'vpn_key' }.fetch(privacy, 'lock')
  end

  # Password protection only ever changes through these two methods, so nothing that does a
  # routine update(privacy: 'public'), like sharing a page, can quietly take it off a document.
  def protect_with_password(password)
    change_password_protection do
      # Assigning a blank password is a no-op, which would leave any earlier one here to pass validation
      @document_password = nil

      self.privacy = 'password'
      self.document_password = password.to_s
      save
    end
  end

  def remove_password_protection(new_privacy)
    change_password_protection do
      self.privacy = new_privacy
      self.document_password = nil
      save
    end
  end

  # What a reader's session keeps after they enter the password. It's tied to the digest,
  # so setting a new password locks out everyone who entered the old one.
  def password_fingerprint
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, "#{id}/#{document_password_digest}").first(16)
  end

  # The digest is sensitive even though it isn't the password itself
  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) + ['document_password_digest']
    super(options)
  end

  # For listing documents alongside other pages. Stricter than #readable_by?, which takes up
  # to three queries per document, and that adds up on pages that list twenty of them.
  scope :public_or_owned_by, ->(user) {
    where('documents.privacy = ? OR documents.user_id = ?', 'public', user&.id)
  }

  # Written out so that documents with no privacy value at all aren't dropped too
  scope :without_passwords_unless_owned_by, ->(user) {
    where("documents.privacy IS NULL OR documents.privacy != 'password' OR documents.user_id = ?", user&.id)
  }

  # Archive scopes and methods (matching IsContentPage pattern)
  scope :unarchived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archive!
    update!(archived_at: DateTime.now)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def archived?
    !archived_at.nil?
  end

  def self.color
    'teal bg-teal-500'
  end

  def self.text_color
    'teal-text text-teal-500'
  end

  def color
    Document.color
  end

  def text_color
    Document.text_color
  end

  def self.hex_color
    '#009688'
  end

  def self.icon
    'description'
  end

  def icon
    Document.icon
  end

  def page_type
    'Document'
  end

  def name
    title
  end

  def description
    self.body
  end

  def universe_field_value
    # TODO: populate value from cache when documents belong to a universe
  end

  def view_path
    document_path(self.id)
  end

  def edit_path
    edit_document_path(self.id)
  end

  def analyze!
    # Create an analysis placeholder to show the user one is queued,
    # then process it async.
    analysis = self.document_analysis.create(queued_at: DateTime.current)
    DocumentAnalysisJob.perform_later(analysis.reload.id)

    # TODO: Should we also be deleting all existing analyses here since they're
    #       now out of date? Or should we wait until the analysis is complete?
  end

  def save_document_revision!
    if (saved_changes.keys & KEYS_TO_TRIGGER_REVISION_ON_CHANGE).any?
      enqueue_debounced(SaveDocumentRevisionJob)
    end
  end

  # Autosave can update a document every few seconds while someone is writing. Rather than queueing
  # a job for every save, queue at most one per document per debounce window, and run it at the end
  # of that window. Jobs load the document when they run, so they still see every edit made before then.
  def enqueue_debounced(job_class)
    wait = self.class.background_job_debounce
    return job_class.perform_later(id) if wait.zero?

    key = "documents/#{id}/#{job_class.name.underscore}/queued"
    return unless Rails.cache.write(key, true, unless_exist: true, expires_in: wait)

    begin
      job_class.set(wait: wait).perform_later(id)
    rescue StandardError
      Rails.cache.delete(key)
      raise
    end
  rescue RedisClient::Error, Redis::BaseError => e
    # Background jobs are not critical; never let Redis trouble fail a save
    Rails.logger.warn "Could not queue #{job_class.name} for Document #{id}: #{e.class}: #{e.message}"
  end

  def self.background_job_debounce
    Rails.application.config.x.document_job_debounce || 30.seconds
  end

  def word_count
    self.cached_word_count || 0 # self.computed_word_count
  end

  def computed_word_count
    return 0 unless self.body && self.body.present?

    WordCountService.count(self.body)
  end

  def reading_estimate
    minutes = 1 + (word_count / 200).to_i

    "~#{minutes} minute read"
  end

  def tagged_text
    @tagged_text ||= begin
      tagger = EngTagger.new
      tagger.add_tags(plaintext)
    end
  end

  private

  def change_password_protection
    @changing_password_protection = true
    yield
  ensure
    @changing_password_protection = false
  end

  def password_protection_changed_explicitly
    return if @changing_password_protection
    return unless privacy_in_database == 'password' || password_protected? || will_save_change_to_document_password_digest?

    errors.add(:privacy, "can't be changed to or from password protected here")
  end
end
