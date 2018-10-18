class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'

  def self.color
    'black'
  end

  def self.icon
    'chrome_reader_mode'
  end

  def name
    title
  end

  def universe_field_value
    #todo when documents belong to a universe
  end
end
