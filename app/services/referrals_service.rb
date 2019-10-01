class ReferralsService < Service
  def self.level_data
    {
      1 => {
        referrals_needed: 1,
        trophy_color:     'brown'
      },
      2 => {
        referrals_needed: 5,
        trophy_color:     'brown'
      },
      3 => {
        referrals_needed: 15,
        trophy_color:     'brown'
      },
      4 => {
        referrals_needed: 30,
        trophy_color:     'brown'
      },
      5 => {
        referrals_needed: 60,
        trophy_color:     'brown'
      },
    }
  end

  def self.level_data_for(user)
    referral_count = user.referrals.count

    level_data.detect do |level, data|
      referral_count >= data[:referrals_needed]
    end
  end
end