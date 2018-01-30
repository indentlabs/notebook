class DeityCharacterPartner < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
end
