class User
  include Mongoid::Document
  field :name, :type => String
  field :email, :type => String
  field :password, :type => String

  validates_presence_of :name, :email, :password
  validates_uniqueness_of :name, :email
end
