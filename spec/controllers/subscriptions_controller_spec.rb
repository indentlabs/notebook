require 'rails_helper'
require 'support/devise'
require 'webmock/rspec'
include Rails.application.routes.url_helpers

RSpec.describe SubscriptionsController, type: :controller do
  before do
    WebMock.disable_net_connect!(allow_localhost: true)

    # Need to stub .save on StripeObject, but this doesn't seem to work
    #allow_any_instance_of(Stripe::StripeObject).to receive(:save)

    # Stub Stripe::Customer.create
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .with(body: { email: "email1@example.com" })
      .to_return(status: 200, body: {id: 'customer-with-card'}.to_json, headers: {})

    # Stub Stripe::Customer.retrieve
    stub_request(:get, "https://api.stripe.com/v1/customers/customer-with-card")
      .to_return(
        status: 200,
        body: {
          id: 'stripe-id',
          sources: {
            total_count: 1,
            data: [Stripe::StripeObject.new]
          },
          subscriptions: {
            total_count: 1,
            data: []
          }
        }.to_json,
        headers: {}
      )

    # Stub downgrading subscription to starter
    stub_request(:post, "https://api.stripe.com/v1/subscriptions")
      .with(body: { customer: "customer-with-card", plan: 'starter' })
      .to_return(status: 200, body: {id: 'stripe-id'}.to_json, headers: {})

    # Stub updating subscription to premium
    stub_request(:post, "https://api.stripe.com/v1/subscriptions")
      .with(body: { customer: "customer-with-card", plan: 'premium' })
      .to_return(status: 200, body: {id: 'stripe-id'}.to_json, headers: {})

    @request.env['devise.mapping'] = Devise.mappings[:user]
    #@user = create(:user)
    #sign_in @user

    @premium_plan = BillingPlan.create(
      name: 'Premium',
      stripe_plan_id: 'premium',
      monthly_cents: 900,
      available: true,
      universe_limit: 5,
      allows_core_content: true,
      allows_extended_content: true,
      allows_collective_content: true,
      allows_collaboration: true
    )

    @free_plan = BillingPlan.create(
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
  end

  describe "User on Starter / no plan changes their plan" do
    it "redirects to payment method form if they don't have a payment method saved" do
      #post :change, {stripe_plan_id: 'premium'}
      #expect redirect
    end

    it "allows upgrading to Premium when they have a payment method saved" do
      # expect(@user.active_subscriptions).to eq([])
      # post :change, {stripe_plan_id: 'premium'}
      # expect(@user.active_billing_plans).to eq([@premium_plan])
    end
  end

  describe "Subscription permissions" do
    describe "Premium subscriptions" do
      it "allows Premium users to create Characters, Locations, and Items" do
      end

      it "allows Premium users to create Creatures, Races, and Religions" do
      end

      it "allows Premium users to create Scenes" do
      end

      it "allows creating more than 5 universes" do
      end
    end

    describe "Starter subscriptions" do
      it "allows Starter users to create Characters, Locations, and Items" do
      end

      it "doesn't allow Starter users to create Creatures, Races, and Religions" do
      end

      it "doesn't allow Starter users to create Scenes" do
      end

      it "allows creating up to five universes" do
      end
    end
  end
end