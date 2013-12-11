class Universe
  include Mongoid::Document

  # General
  field :name,        :type => String
  field :description, :type => String
  
  # History
  field :history,  :type => String

  # More...
	
  belongs_to :user
end
