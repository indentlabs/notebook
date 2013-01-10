class Universe
  include Mongoid::Document

	# General
  field :name,        :type => String
  field :description, :type => String
	
	# More...
	
  belongs_to :user
end
