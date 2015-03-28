##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  validates :name, presence: true
  validates :password, presence: true
  validates :email, presence: true

  before_save :hash_password

  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :universes

  def hash_password
    require 'digest'
    self.password = Digest::MD5.hexdigest(
      name + "'s password IS... " + password + ' (lol!)')
  end

  def content
    {
      characters: characters,
      equipment: equipment,
      languages: languages,
      locations: locations,
      magics: magics,
      universes: universes
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
