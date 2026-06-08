class PageUnlockPromoCode < ApplicationRecord
  has_many :promotions, dependent: :destroy
  has_many :users, -> { distinct }, through: :promotions

  serialize :page_types, Array

  before_save do
    # Whitelist page types to ensure we're only saving promo codes for actual pages :)
    self.page_types = page_types & Rails.application.config.content_types[:all].map(&:name)
  end

  # Returns true if the code was activated for the user on this call, false otherwise
  # (no uses left, missing user, or already activated by this user).
  #
  # The whole check-decrement-grant runs under a row lock so two concurrent requests can't both
  # consume the last use or double-activate the same user.
  def activate!(user)
    return false unless user.present?

    activated = false
    with_lock do
      next if uses_remaining <= 0
      next if users.exists?(id: user.id)

      update!(uses_remaining: uses_remaining - 1)

      page_types.each do |page_type|
        promotions.create!(
          user:         user,
          content_type: page_type,
          expires_at:   DateTime.current + days_active.days,
        )
      end

      activated = true
    end

    activated
  end
end
