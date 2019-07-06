class PageUnlockPromoCode < ApplicationRecord
  has_many :promotions, as: :promo_code
  has_many :users, through: :promotions

  def unlocked_page_types
    page_types.split('|') & Rails.application.config.content_types[:all]
  end

  def activate!(user)
    return unless uses_remaining > 0

    # Make sure this user hasn't activated this promo code before
    return unless user.present?
    return if users.where(id: user.id).any?

    # Activate!
    # technically two requests at the same time could still double-activate at 
    # 1 use left, but this seems not worth it to fix
    update(uses_remaining: uses_remaining - 1)
  
    unlocked_page_types.each do |page_type|
      promotions.create(
        user:         user,
        content_type: page_type,
        expires_at:   DateTime.current + days_active.days,
      )
    end
  end
end
