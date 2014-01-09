class Equipment
  include Mongoid::Document
  
  # General
  field :name,       :type => String
  field :equip_type, :type => String
  
  # Appearance
  field :description, :type => String
  field :weight, :type => String
  
  # History
  field :original_owner, :type => String
  field :current_owner, :type => String
  field :made_by, :type => String
  field :materials, :type => String
  field :year_made, :type => String
  
  # Abilities
  field :magic, :type => String # Magical Properties
  
  # More
  field :notes, :type => String

  belongs_to :user
  belongs_to :universe
end
