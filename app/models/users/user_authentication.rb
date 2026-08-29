##
# Links a User to an external OAuth identity (e.g. Google, Discord).
# A user may have multiple authentications, one per provider account.
class UserAuthentication < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
end
