class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  has_many :document_analysis

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
end
