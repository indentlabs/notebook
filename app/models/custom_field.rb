class CustomField
  include Mongoid::Document
  field :key, :type => String
  field :value, :type => String
  field :section, :type => String

  belongs_to :character
end
