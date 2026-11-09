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

  # Revision history is append-only: each revision is a version of this document, kept just before
  # a save replaced it, and never changed afterwards. The current version is the document itself.
  # A version is kept on the first save after REVISION_INTERVAL without one (so the end of every
  # writing session is kept, dated when it was written), and whenever a save removes a lot of text.
  REVISION_INTERVAL = 5.minutes
  LARGE_REMOVAL_WORDS = 50
  LARGE_REMOVAL_SHARE = 0.25

  def save_document_revision!
    record_starting_word_count! if saved_change_to_body?
    # Any save, not only text: a status or folder change after a break keeps the end of the previous
    # session, dated when it was written, before the next text save would replace it.
    keep_replaced_version!

    if (saved_changes.keys & KEYS_TO_TRIGGER_REVISION_ON_CHANGE).any?
      enqueue_debounced(SaveDocumentRevisionJob)
    end
  end

  def keep_replaced_version!
    old_body = body_before_last_save.to_s
    return if old_body.blank?

    last_kept_at = document_revisions.order(created_at: :desc, id: :desc).pick(:created_at)
    due = (last_kept_at || created_at) <= REVISION_INTERVAL.ago
    return unless due || large_removal?(old_body)

    keep_version!(
      { title: title_before_last_save, body: old_body, synopsis: synopsis_before_last_save,
        notes_text: notes_text_before_last_save, universe_id: universe_id_before_last_save },
      saved_at: updated_at_before_last_save
    )
  rescue StandardError => e
    # History must never fail a save
    Rails.logger.warn "Could not keep a revision of Document #{id}: #{e.class}: #{e.message}"
  end

  # Restore calls this before replacing the current version
  def keep_current_version!
    keep_version!(slice(:title, :body, :synopsis, :notes_text, :universe_id).symbolize_keys, saved_at: updated_at)
  end

  # Whether a version holds the same text as this document (so restoring it would change nothing)
  def same_text_as?(version)
    self.class.same_text?(self, version)
  end

  # The fields a version keeps, compared as text (works on documents, revisions and attribute hashes)
  def self.same_text?(a, b)
    %i[title body synopsis notes_text].all? { |field| a[field].to_s == b[field].to_s }
  end

  # On the first change to the body each day, store the count the day started from, measured on the
  # text from just before this save. SaveDocumentRevisionJob then keeps that day's word_count up to
  # date, so the day's words are what was written that day: not everything since the document's
  # last tracked day, not text that was imported or pasted in before the first edit, and not a
  # difference between the old and new ways of counting.
  def record_starting_word_count!
    date = WordCountUpdate.date_for(user)
    row = word_count_updates.find_by(for_date: date)
    return if row&.starting_word_count

    starting_count = WordCountService.count(body_before_last_save)

    if row
      # The day's row was written before starting counts were recorded (by a save earlier today).
      # Keep the words it already credited today, and measure the rest of the day from now on.
      row.convert_to_starting_count!(starting_count)
    else
      if updated_at_before_last_save
        record_untracked_writing!(saved_at: updated_at_before_last_save, word_count: starting_count)
      end
      WordCountUpdate.record!(self, date: date, word_count: starting_count) { starting_count }
    end
  rescue StandardError => e
    # Word tracking must never fail a save
    Rails.logger.warn "Could not record the starting word count for Document #{id}: #{e.class}: #{e.message}"
  end

  # Records writing that was saved on an earlier day with no word count row (its job never ran, as
  # while the debounce lock was stuck in late 2026) on that day, measured from the last day that was
  # tracked. word_count is the document's count as it was at saved_at.
  def record_untracked_writing!(saved_at:, word_count:)
    day = WordCountUpdate.date_for(user, saved_at)
    return unless day < WordCountUpdate.date_for(user)
    return if word_count_updates.exists?(for_date: day)

    last_tracked = word_count_updates.where('for_date < ?', day).order(for_date: :desc).first
    return if last_tracked.nil? # never tracked, so there's nothing to measure from

    starting_count = last_tracked_count(last_tracked)
    return unless word_count > starting_count

    WordCountUpdate.record!(self, date: day, word_count: word_count) { starting_count }
  end

  # Restoring a revision changes the word count without anyone writing. Move today's starting count
  # by the same amount, so the restored words aren't counted as written today (and words written
  # earlier today still are). Never fails the restore: it has already happened.
  def discount_restored_words!(words_restored, word_count_now:)
    return if words_restored.zero?

    row = word_count_updates.find_by(for_date: WordCountUpdate.date_for(user))
    return if row.nil?

    row.update!(starting_word_count: row.starting_count + words_restored, word_count: word_count_now)
  rescue StandardError => e
    Rails.logger.warn "Could not discount restored words for Document #{id}: #{e.class}: #{e.message}"
  end

  # Autosave can update a document every few seconds while someone is writing. Rather than queueing
  # a job for every save, queue at most one per document per debounce window, and run it at the end
  # of that window. Jobs load the document when they run, so they still see every edit made before then.
  def enqueue_debounced(job_class)
    wait = self.class.background_job_debounce
    return job_class.perform_later(id) if wait.zero?

    key = "documents/#{id}/#{job_class.name.underscore}/queued"
    return unless CacheLock.acquire(key, expires_in: wait)

    begin
      job_class.set(wait: wait).perform_later(id)
    rescue StandardError
      CacheLock.release(key)
      raise
    end
  rescue RedisClient::Error, Redis::BaseError => e
    # Background jobs are not critical; never let Redis trouble fail a save
    Rails.logger.warn "Could not queue #{job_class.name} for Document #{id}: #{e.class}: #{e.message}"
  end

  # Unset config.x keys return an empty (truthy) OrderedOptions rather than nil,
  # so `|| default` never kicks in; only use the setting if it's a number.
  def self.background_job_debounce
    wait = Rails.application.config.x.document_job_debounce
    wait.is_a?(Numeric) ? wait : 30.seconds
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

  def keep_version!(version, saved_at:)
    newest = document_revisions.order(created_at: :desc, id: :desc).first
    return if newest && self.class.same_text?(newest, version)

    # created_at is when it was kept, which spaces versions REVISION_INTERVAL apart. updated_at is
    # when its text was saved, which is what the history shows.
    document_revisions.create!(version.merge(cached_word_count: WordCountService.count(version[:body]), updated_at: saved_at))
  end

  def large_removal?(old_body)
    old_count = cached_word_count_before_last_save.to_i
    threshold = old_count > 0 ? [LARGE_REMOVAL_WORDS, (old_count * LARGE_REMOVAL_SHARE).ceil].min : LARGE_REMOVAL_WORDS
    TextChange.removed_at_least?(old_body, body.to_s, threshold)
  end

  # The count a tracked day ended on. Rows from before starting counts were recorded hold a count
  # made the old way; the revision kept the same day holds that text, counted the current way.
  def last_tracked_count(row)
    return row.word_count.to_i unless row.starting_word_count.nil?

    zone = Time.find_zone(user&.time_zone.presence) || Time.find_zone('UTC')
    revision = document_revisions.where(updated_at: row.for_date.in_time_zone(zone).all_day).order(updated_at: :desc).first
    revision ? WordCountService.count(revision.body) : row.word_count.to_i
  end

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
