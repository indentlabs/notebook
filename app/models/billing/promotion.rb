class Promotion < ApplicationRecord
  belongs_to :user

  belongs_to :page_unlock_promo_code

  # belongs_to :promo_code, polymorphic: true
  def promo_code
    page_unlock_promo_code
  end

  scope :active, -> { where('expires_at > ?', DateTime.now) }
end
