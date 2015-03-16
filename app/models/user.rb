class User < ActiveRecord::Base
  validates_presence_of :name, :password, :email
  
  before_save :hash_password

  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :universes
  
  def hash_password
    require 'digest'
    self.password = Digest::MD5.hexdigest(self.name + "'s password IS... " + self.password + " (lol!)")
  end
  
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
