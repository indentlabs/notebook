class DeityDeityPartner < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :deity_partner, class_name: Deity.name
end
