class Referral < ActiveRecord::Base
  def referrer
    User.find_by(id: self.referrer_id)
  end
end
