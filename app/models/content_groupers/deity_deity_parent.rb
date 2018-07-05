class DeityDeityParent < ActiveRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :deity_parent, class_name: Deity.name
end
