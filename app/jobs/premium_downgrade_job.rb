class PremiumDowngradeJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    user_id = args.shift

    user = User.find_by(id: user_id)
    raise "No user to downgrade; id=#{user_id}" if user.nil?

    # Remove any bonus bandwidth granted by the plan
    premium_bandwidth_bonus = BillingPlan.find(4).bonus_bandwidth_kb
    user.update!(upload_bandwidth_kb: user.upload_bandwidth_kb - premium_bandwidth_bonus)
  end

end