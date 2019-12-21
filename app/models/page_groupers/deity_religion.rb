class DeityReligion < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :religion
end
