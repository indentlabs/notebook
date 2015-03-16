class Session < ActiveRecord::Base
  validates_presence_of :username, :password
end
