class DeityReligion < ActiveRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :religion
end
