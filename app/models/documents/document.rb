class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :user,     optional: true

  has_many :document_analysis,   dependent: :destroy
  has_many :document_entities,   through: :document_analysis
  has_many :document_concepts,   through: :document_analysis
  has_many :document_categories, through: :document_analysis

  has_many :document_revisions, dependent: :destroy
  after_update :save_document_revision!

  include HasParseableText
  include HasPartsOfSpeech
  include HasImageUploads
  include HasPageTags
  include BelongsToUniverse

  belongs_to :folder, optional: true

  # TODO: include IsContentPage ?

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  attr_accessor :tagged_text

  KEYS_TO_TRIGGER_REVISION_ON_CHANGE = %w(title body synopsis notes_text)

  def self.color
    'teal'
  end

  def self.text_color
    'teal-text'
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
      SaveDocumentRevisionJob.perform_later(self.id)
    end
  end

  def word_count
    self.cached_word_count || 0 # self.computed_word_count
  end

  def computed_word_count
    return 0 unless self.body && self.body.present?

    # Settings: https://github.com/diasks2/word_count_analyzer
    # TODO: move this into analysis services & call that here
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
