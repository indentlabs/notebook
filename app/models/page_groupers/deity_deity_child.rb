class DeityDeityChild < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :deity_child, class_name: Deity.name
end
