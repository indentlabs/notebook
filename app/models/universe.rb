class Universe
  include Mongoid::Document

  # General
  field :name,        :type => String
  field :description, :type => String
  
  # History
  field :history,  :type => String

  # More...

  # Settings
  field :privacy, :type => String # Whether or not this universe is public, options are 'private' or 'public'
	
  belongs_to :user
end
