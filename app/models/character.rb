class Character
  include Mongoid::Document
  field :name, :type => String
  field :age, :type => String

  belongs_to :user
end
