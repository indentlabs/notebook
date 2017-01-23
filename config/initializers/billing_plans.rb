# Set up all the available billing plans. Requires a server restart to take effect.

# BillingPlan Fields:
# - name: The name we show to users when viewing their current plan or choosing a new one
# - stripe_plan_id: Must match the corresponding Subscription plan on Stripe
# - monthly_cents: The price of the plan, charged monthly (e.g. $9/month is 900 cents)
# - available: Whether or not this plan is available for users to choose on their own (from the subscription UI)

# Limitations:
# - universe_limit: Number of universes that can be created while on this plan. Existing ones can always be edited.
# - allows_core_content: Whether or not to allow creating new core content. Existing ones can always be edited.
# - allows_extended_content: Whether or not to allow creating new extended content. Existing ones can always be edited.
# - allows_collective_content: Whether or not to allow creating new collective content. Existing ones can always be edited.
# - allows_collaboration: Whether or not this user can invite other users to contribute to their universe (TBD)

# Free tier
BillingPlan.find_or_create_by(
  name: 'Starter',
  stripe_plan_id: 'starter',
  monthly_cents: 0, # $0.00/mo
  available: true,

  # Content creation and other permissions:
  universe_limit: 5,
  allows_core_content: true,
  allows_extended_content: false,
  allows_collective_content: false,
  allows_collaboration: false
)

# Free-for-life plan for beta testers
BillingPlan.find_or_create_by(
  name: 'Beta Testers - Free For Life (thank you!)',
  stripe_plan_id: 'free-for-life',
  monthly_cents: 0, # $0.00/mo
  available: false,

  # Content creation and other permissions:
  universe_limit: 1000,
  allows_core_content: true,
  allows_extended_content: true,
  allows_collective_content: true,
  allows_collaboration: true
)

# Temporary $6/month paid tier for users that sign up before February 14
BillingPlan.find_or_create_by(
  name: 'Early Adopters (thank you!)',
  stripe_plan_id: 'early-adopters',
  monthly_cents: 600, # $6.00/mo
  available: true,

  # Content creation and other permissions:
  universe_limit: 1000,
  allows_core_content: true,
  allows_extended_content: true,
  allows_collective_content: true,
  allows_collaboration: false
)

# Standard $9/month paid tier (to be available after signup promo)
BillingPlan.find_or_create_by(
  name: 'Premium',
  stripe_plan_id: 'premium',
  monthly_cents: 900, # $9.00/mo
  available: false,

  # Content creation and other permissions:
  universe_limit: 1000,
  allows_core_content: true,
  allows_extended_content: true,
  allows_collective_content: true,
  allows_collaboration: false
)
