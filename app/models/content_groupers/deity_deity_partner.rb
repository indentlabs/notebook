class DeityDeityPartner < ActiveRecord::Base
  belongs_to :user
  belongs_to :deity
  belongs_to :deity_partner, class_name: Deity.name
end
