class SubscriptionsController < ApplicationController
  def new
    # We only support a single billing plan right now, so just grab the first one. If they don't have an active plan,
    # we also treat them as if they have a Starter plan.
    @active_billing_plan = current_user.active_billing_plans.first || BillingPlan.find_by(stripe_plan_id: 'starter')
  end

  def show
  end
end
