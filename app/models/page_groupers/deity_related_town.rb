class DeityRelatedTown < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :related_town, class_name: Town.name, optional: true
end
