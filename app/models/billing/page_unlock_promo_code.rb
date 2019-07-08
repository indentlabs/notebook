class PageUnlockPromoCode < ApplicationRecord
  has_many :promotions
  has_many :users, -> { distinct }, through: :promotions

  serialize :page_types, Array

  before_save do
    # Whitelist page types to ensure we're only saving promo codes for actual pages :)
    self.page_types = page_types & Rails.application.config.content_types[:all].map(&:name)
  end

  def activate!(user)
    return false unless uses_remaining > 0

    # Make sure this user hasn't activated this promo code before
    return false unless user.present?
    return false if users.pluck(:id).include?(user.id)

    # Activate!
    # technically two requests at the same time could still double-activate at 
    # 1 use left, but this seems not worth it to fix
    update(uses_remaining: uses_remaining - 1)
  
    page_types.each do |page_type|
      promotions.create(
        user:         user,
        content_type: page_type,
        expires_at:   DateTime.current + days_active.days,
      )
    end

    return true
  end
end
