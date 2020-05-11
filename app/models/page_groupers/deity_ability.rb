class DeityAbility < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :ability, class_name: Magic.name, optional: true
end
