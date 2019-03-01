class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  has_many :document_analysis,   dependent: :destroy
  has_many :document_entities,   through: :document_analysis
  has_many :document_concepts,   through: :document_analysis
  has_many :document_categories, through: :document_analysis

  include HasParseableText
  include HasPartsOfSpeech

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  def self.color
    'teal'
  end

  def self.hex_color
    '#009688'
  end

  def self.icon
    'description'
  end

  def name
    title
  end

  def universe_field_value
    #todo when documents belong to a universe
  end

  def analyze!
    # Create an analysis placeholder to show the user one is queued,
    # then process it async
    analysis = self.document_analysis.create
    DocumentAnalysisJob.perform_later(analysis.reload.id)
  end
end
