class Promotion < ApplicationRecord
  belongs_to :user

  # belongs_to :promo_code, polymorphic: true
  belongs_to :page_unlock_promo_code

  scope :active, -> { where('expires_at > ?', DateTime.now) }
end
