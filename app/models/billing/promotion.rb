class Promotion < ApplicationRecord
  belongs_to :user
  belongs_to :promo_code, polymorphic: true

  scope :active, -> { where('expires_at > ?', DateTime.now) }
end
