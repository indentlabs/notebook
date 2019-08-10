class DeityReligion < ApplicationRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :religion
end
