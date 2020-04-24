class DeityDeityParent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :deity
  belongs_to :deity_parent, class_name: Deity.name, optional: true
end
