class Magic
  include Mongoid::Document
  
  # General
  field :name, :type => String
  field :type_of, :type => String # "Type of": Spell, Ability, Enchantment, etc
  
  # Appearance
  field :manifestation, :type => String
  field :symptoms, :type => String
  
  # Alignment
  field :element, :type => String
  field :diety, :type => String
  
  # Effects
  field :harmfulness, :type => String # Harmful effects
  field :helpfulness, :type => String # Helpful effects
  
  # More

  belongs_to :user
end
