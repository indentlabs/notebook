class User
  include Mongoid::Document
  field :name, :type => String
  field :email, :type => String
  field :password, :type => String

  validates_presence_of :name, :email, :password
  validates_uniqueness_of :name, :email
  
  before_create :hash_password
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

  def characters
    Character.where(user_id: id)
  end

  def equipment
    Equipment.where(user_id: id)
  end

  def languages
    Language.where(user_id: id)
  end

  def locations
    Location.where(user_id: id)
  end

  def magics
    Magic.where(user_id: id)
  end

  def universes
    Universe.where(user_id: id)
  end
  
end
