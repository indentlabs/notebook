# FINDS users that are on a premium account on Notebook.ai but not a premium account on Stripe
# In other words, they are getting free service on Notebook.ai.

billing_plan_lookup = {
  3 => 'early-adopters',
  4 => 'premium',
  5 => 'premium-trio',
  6 => 'premium-annual'
}

users_to_downgrade = []
User.where(selected_billing_plan_id: 4).find_each do |user|
  print '.'
  active_stripe_plan = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.data[0]

  if active_stripe_plan.nil?
    users_to_downgrade << user
    next
  end

  active_stripe_plan = active_stripe_plan.plan.id
  if active_stripe_plan != billing_plan_lookup[user.selected_billing_plan_id]
    users_to_downgrade << user
  end
end
puts "Done!"
puts users_to_downgrade.map { |u| [u.id, u.email] }






users_to_downgrade.each do |user|
  user.update(selected_billing_plan_id: 1)
end
