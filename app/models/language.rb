class Language
  include Mongoid::Document
  
  # General
  field :name, :type => String
  
  # Vocabulary
  field :words, :type => String
  
  # History
  field :established_year, :type => String
  field :established_location, :type => String
  
  # Speakers
  field :characters, :type => String
  field :locations, :type => String
  
  # More
  field :notes, :type => String

  belongs_to :user
  belongs_to :universe
end
