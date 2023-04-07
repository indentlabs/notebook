class BasilFeedback < ApplicationRecord
  belongs_to :basil_commission
  belongs_to :user
end
