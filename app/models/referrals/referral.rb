class Referral < ApplicationRecord
  def referrer
    User.find_by(id: self.referrer_id)
  end

  def referree
    User.find_by(id: self.referred_id)
  end
end
