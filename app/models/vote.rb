class Vote < ActiveRecord
  belongs_to :user
  belongs_to :votable
end
