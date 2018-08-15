class DeityRelatedTown < ApplicationRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :related_town, class_name: Town.name
end
