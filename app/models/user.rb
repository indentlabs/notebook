##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :name,  presence: true
  validates :email, presence: true

  has_many :characters
  has_many :items
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :universes

  def content
    {
      characters: characters,
      items: items,
      languages: languages,
      locations: locations,
      magics: magics,
      universes: universes
    }
  end

  def content_count
    [
      characters.length,
      items.length,
      languages.length,
      locations.length,
      magics.length,
      universes.length
    ].sum
  end
end
