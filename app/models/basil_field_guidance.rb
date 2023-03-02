class BasilFieldGuidance < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :user
end
