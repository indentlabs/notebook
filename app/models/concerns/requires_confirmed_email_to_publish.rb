require 'active_support/concern'

# Making something public puts it in front of everyone, so its owner has to have confirmed their
# email address first (see User#can_publish?). Saves that don't change privacy aren't affected.
module RequiresConfirmedEmailToPublish
  extend ActiveSupport::Concern

  CONFIRMATION_REQUIRED_ERROR = "can't be public until you've confirmed your email address".freeze

  included do
    validate :owner_can_publish, if: -> { will_save_change_to_privacy? && privacy == 'public' }
  end

  private

  def owner_can_publish
    owner = try(:user)
    return if owner.nil? || owner.can_publish?

    errors.add(:privacy, CONFIRMATION_REQUIRED_ERROR)
  end
end
