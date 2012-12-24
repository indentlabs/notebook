class Character
  include Mongoid::Document
  
  # Appearance
  field :name,      :type => String
  #gender
  field :age,       :type => String
  field :height,    :type => String
  field :weight,    :type => String
  field :haircolor, :type => String
  field :hairstyle, :type => String
  field :eyecolor,  :type => String
  #race
  field :skintone,  :type => String
  field :bodytype,  :type => String
  field :identmarks, :type => String # Identifying marks
  
  # Social
  #best friend
  #religion
  #politics
  #prejudices
  #job
  #pet
  #How might others describe him?
  #What would others change about him?
  
  # Behavior
  #mannerisms
  #What drives this character?
  #What is standing in his way?
  #What is he most afraid of?
  #What does he need most?
  #What makes him vulnerable?
  #What kind of trouble does he get in?
  
  # History
	#birthday
  #born at
	#schooled at
	#What is his deepest secret?
	#Does he have a history of criminal activity?

	# Favorites
	#color
	#food
	#possession
	#weapon
	#animal
	#leisure activities
	
	# Relationships
	#father
	#mother
	#spouse
	#siblings
	#friends
	#enemies
	#pets
	
	# More...
	#additional notes
	#additional fields

  belongs_to :user
end
