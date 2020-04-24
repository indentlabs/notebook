class ReligionDeity < ActiveRecord::Base
  belongs_to :user, optional: true

  belongs_to :religion
  belongs_to :deity, optional: true
end
