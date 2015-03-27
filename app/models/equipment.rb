class Equipment < ActiveRecord::Base
  include Comparable
  
  validates_presence_of :name

  belongs_to :user
  belongs_to :universe
  
  before_save :nil_blank_universe
  
  def <=>(anOther)
    name.downcase <=> anOther.name.downcase
  end

  def nil_blank_universe
    self.universe = nil if universe.blank?
  end
end
