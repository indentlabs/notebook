class TimelineEvent < ApplicationRecord
  acts_as_paranoid

  belongs_to :timeline, touch: true

  has_many :timeline_event_entities, dependent: :destroy

  acts_as_list scope: [:timeline_id]

  # todo move this to a real permissions authorizer
  def can_be_modified_by?(user)
    user == timeline.user
  end
end
