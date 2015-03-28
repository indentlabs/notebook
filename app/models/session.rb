##
# A currently-logged-in User
class Session < ActiveRecord::Base
  validates :username, presence: true
  validates :password, presence: true
end
