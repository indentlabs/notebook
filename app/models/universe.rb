class Universe < ActiveRecord::Base
  belongs_to :user
  has_many :characters
  has_many :equipment
  has_many :languages
  has_many :locations
  has_many :magics
  
  def content_count
    [
      characters.length,
      equipment.length,
      languages.length,
      locations.length,
      magics.length,
    ].sum
  end
end
