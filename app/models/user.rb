class User < ActiveRecord::Base
  validates_presence_of :name, :password, :email
  
  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :universes
  
  def content
    {
      :characters => characters,
      :equipment  => equipment,
      :languages  => languages,
      :locations  => locations,
      :magics     => magics,
      :universes  => universes
    }
  end
  
  def content_count
    [
      characters.length, 
      equipment.length, 
      languages.length, 
      locations.length, 
      magics.length, 
      universes.length
    ].sum
  end
end
