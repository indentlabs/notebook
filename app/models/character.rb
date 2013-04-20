class Character
  include Mongoid::Document

	# General
  field :name,       :type => String
	field :role,       :type => String
  field :gender,     :type => String
  field :age,        :type => String

  # Appearance
  field :height,     :type => String
  field :weight,     :type => String
  field :haircolor,  :type => String
  field :hairstyle,  :type => String
  field :eyecolor,   :type => String
  field :race,       :type => String
  field :skintone,   :type => String
  field :bodytype,   :type => String
  field :identmarks, :type => String # Identifying marks

  # Social
  field :bestfriend, :type => String
  field :religion, :type => String
  field :politics, :type => String
  field :prejudices, :type => String
  field :occupation, :type => String
  field :pets, :type => String
  #How might others describe him?
  #What would others change about him?
  
  # Behavior
  field :mannerisms, :type => String
  #What drives this character?
  #What is standing in his way?
  #What is he most afraid of?
  #What does he need most?
  #What makes him vulnerable?
  #What kind of trouble does he get in?
  
  # History
  field :birthday, :type => String
  field :birthplace, :type => String
  field :education, :type => String
  field :background, :type => String
	#What is his deepest secret?
	#Does he have a history of criminal activity?

	# Favorites
	field :fave_color, :type => String
	field :fave_food, :type => String
	field :fave_possession, :type => String
	field :fave_weapon, :type => String
	field :fave_animal, :type => String
	#favorite leisure activities
	
	# Relationships
	field :father, :type => String
	field :mother, :type => String
	field :spouse, :type => String
	field :siblings, :type => String
	field :archenemy, :type => String
	
	# More...
	field :notes, :type => String
	#additional fields

  belongs_to :user
  belongs_to :universe
end
