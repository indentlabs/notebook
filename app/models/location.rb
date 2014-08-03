class Location < ActiveRecord::Base
  has_attached_file :map,  :styles => { :original => "1920x1080>", :thumb => "200x200>" }
  validates_attachment_content_type :map, :content_type => /\Aimage\/.*\Z/
  validates_presence_of :name
  
  belongs_to :user
  belongs_to :universe
end
