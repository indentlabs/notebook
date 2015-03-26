class Character < ActiveRecord::Base
  include Comparable
  
  validates_presence_of :name
  
  belongs_to :user
  belongs_to :universe
  
  def <=>(anOther)
    name.downcase <=> anOther.name.downcase
  end
  
  def nil_blank_universe
    self.universe = nil if self.universe.blank?
  end
end
