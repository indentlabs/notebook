class DeityFlora < ActiveRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :flora
end
