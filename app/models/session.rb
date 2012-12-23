class Session
  include Mongoid::Document
  field :username, :type => String
  field :password, :type => String
end
