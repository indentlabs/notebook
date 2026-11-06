class ShareComment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, optional: true # now that we're auto-deleting this data, we can probably remove this constraint without db errors
  belongs_to :content_page_share

  validate :commenter_can_publish, on: :create

  def from_op?(share)
    user == share.user
  end

  private

  # Comments are shown to everyone who can see the share (see User#can_publish?)
  def commenter_can_publish
    return if user.nil? || user.can_publish?

    errors.add(:base, User::CONFIRM_EMAIL_TO_PUBLISH_MESSAGE)
  end
end
