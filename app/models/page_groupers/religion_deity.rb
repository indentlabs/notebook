class ReligionDeity < ActiveRecord::Base
  belongs_to :user

  belongs_to :religion
  belongs_to :deity
end
