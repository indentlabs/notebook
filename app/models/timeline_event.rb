class TimelineEvent < ApplicationRecord
  belongs_to :timeline

  acts_as_list scope: [:timeline_id]

  # todo move this to a real permissions authorizer
  def can_be_modified_by?(user)
    user == timeline.user
  end
end
