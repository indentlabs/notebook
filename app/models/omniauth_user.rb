class OmniauthUser < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true

  def self.from_omniauth(auth, current_user)
    omniauth_user = find_by(provider: auth.provider, uid: auth.uid)
    return omniauth_user.user if omniauth_user.present?

    user = current_user ||
           User.find_by(email: auth.info.email) ||
           User.create(email: auth.info.email, password: Devise.friendly_token[0,20], name: auth.info.name)
    user.omniauth_users.build(provider: auth.provider, uid: auth.uid, email: auth.info.email)
    user.save
    user
  end
end
