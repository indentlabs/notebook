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

  def content_count
    [
      characters.length,
      equipment.length,
      languages.length,
      locations.length,
      magics.length,
    ].sum
  end

  def characters
    Character.where(universe_id: id)
  end

  def equipment
    Equipment.where(universe_id: id)
  end

  def languages
    Language.where(universe_id: id)
  end

  def locations
    Location.where(universe_id: id)
  end

  def magics
    Magic.where(universe_id: id)
  end

end
