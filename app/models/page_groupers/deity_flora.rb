class DeityFlora < ApplicationRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :flora
end
