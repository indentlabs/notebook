##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :name, presence: true
  validates :email, presence: true

  has_secure_password
  before_save :hash_old_password

  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :universes

  def hash_old_password
    require 'digest'

    return if old_password.blank?

    self.old_password = Digest::MD5.hexdigest(
      name + "'s password IS... " + old_password + ' (lol!)')
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
