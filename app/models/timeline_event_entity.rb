class TimelineEventEntity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :timeline_event
end
