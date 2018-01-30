class DeityFlora < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :flora
end
