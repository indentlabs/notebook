class DeityCharacterParent < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
end
