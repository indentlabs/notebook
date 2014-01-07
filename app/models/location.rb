class Location
  include Mongoid::Document
  include Mongoid::Paperclip
  
  # General
  field :name, :type => String
  field :type_of, :type => String
  field :description, :type => String
  
  # Map
  has_mongoid_attached_file :map, styles: {
    original: '1920x1680>',
    thumb:    '200x200>',
  }

  # Culture
  field :population, :type => String
  field :language, :type => String
  field :currency, :type => String
  field :motto, :type => String
  #field :flag, :type => Image
  #field :seal, :type => Image
  
  # Cities
  field :capital, :type => String
  field :largest_city, :type => String
  field :notable_cities, :type => String
  
  # Geography
  field :area, :type => String
  field :crops, :type => String
  field :located_at, :type => String
  
  # History
  field :established_year, :type => String
  field :notable_wars, :type => String
  
  # More
  field :notes, :type => String

  belongs_to :user
end
