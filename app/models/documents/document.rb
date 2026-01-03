class Document < ApplicationRecord
  include Rails.application.routes.url_helpers
  acts_as_paranoid

  belongs_to :user,     optional: true

  has_many :document_analysis,   dependent: :destroy
  has_many :document_entities,   through: :document_analysis
  has_many :document_concepts,   through: :document_analysis
  has_many :document_categories, through: :document_analysis

  has_many :document_revisions, dependent: :destroy
  after_update :save_document_revision!

  has_many :book_documents, dependent: :destroy
  has_many :books, through: :book_documents

  include HasParseableText
  include HasPartsOfSpeech
  include HasImageUploads
  include HasPageTags
  include BelongsToUniverse
  include HasPrivacy

  belongs_to :folder, optional: true

  # TODO: include IsContentPage ?

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  attr_accessor :tagged_text

  # Duplicated from is_content_page since we don't include that here yet
  has_many :word_count_updates, as: :entity, dependent: :destroy
  def latest_word_count_cache
    word_count_updates.order('for_date DESC').limit(1).first.try(:word_count) ||  0
  end

  KEYS_TO_TRIGGER_REVISION_ON_CHANGE = %w(title body synopsis notes_text)

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
      begin
        SaveDocumentRevisionJob.perform_later(self.id)
      rescue RedisClient::CannotConnectError, Redis::CannotConnectError => e
        # Log the error but don't fail the save - document revisions are not critical
        Rails.logger.warn "Could not save document revision due to Redis connection error: #{e.message}"
      end
    end
  end

  def word_count
    self.cached_word_count || 0 # self.computed_word_count
  end

  def computed_word_count
    return 0 unless self.body && self.body.present?

    # Settings: https://github.com/diasks2/word_count_analyzer
    # TODO: move this into analysis services & call that here
    if false && self.body.length <= 10_000
      WordCountAnalyzer::Counter.new(
        ellipsis:          'no_special_treatment',
        hyperlink:         'count_as_one',
        contraction:       'count_as_one',
        hyphenated_word:   'count_as_one',
        date:              'no_special_treatment',
        number:            'count',
        numbered_list:     'ignore',
        xhtml:             'remove',
        forward_slash:     'count_as_multiple_except_dates',
        backslash:         'count_as_one',
        dotted_line:       'ignore',
        dashed_line:       'ignore',
        underscore:        'ignore',
        stray_punctuation: 'ignore'
      ).count(self.body)
    else
      # For really long documents, use a faster approach to estimate word count
      # Strip HTML tags first to avoid counting tag names like <p> as words
      ActionController::Base.helpers.strip_tags(self.body).scan(/\b\w+\b/).count
    end
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
end
