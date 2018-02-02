class DeityAbility < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :ability, class_name: Magic.name
end
