class Votable < ActiveRecord::Base
  has_many :votes
end
