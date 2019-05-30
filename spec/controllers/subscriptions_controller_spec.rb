require 'rails_helper'
require 'support/devise'
require 'webmock/rspec'
include Rails.application.routes.url_helpers

RSpec.describe SubscriptionsController, type: :controller do
  before do
    WebMock.disable_net_connect!(allow_localhost: true)

    # Need to stub .save on StripeObject, but this doesn't seem to work
    #Stripe::StripeObject.any_instance.stub(:save).and_return(true)

    # Stub Stripe::Customer.create
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .with(body: { email: "email1@example.com" })
      .to_return(status: 200, body: {id: 'stripe-id'}.to_json, headers: {})

    # Stub Stripe::Customer.retrieve
    stub_request(:get, "https://api.stripe.com/v1/customers/stripe-id")
      .to_return(
        status: 200,
        body: {
          id: 'stripe-id',
          sources: {
            total_count: 0,
            data: []
          },
          subscriptions: {
            total_count: 1,
            data: [Stripe::StripeObject.new]
          }
        }.to_json,
        headers: {}
      )

    # Stub downgrading subscription to starter
    stub_request(:post, "https://api.stripe.com/v1/subscriptions")
      .with(body: { customer: "stripe-id", plan: 'starter' })
      .to_return(status: 200, body: {id: 'stripe-id'}.to_json, headers: {})

    # Stub updating subscription to premium
    stub_request(:post, "https://api.stripe.com/v1/subscriptions")
      .with(body: { customer: "stripe-id", plan: 'premium' })
      .to_return(status: 200, body: {id: 'stripe-id'}.to_json, headers: {})

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = create(:user)
    @user.update(stripe_customer_id: 'stripe-id')
    sign_in @user

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
      allows_collaboration: false,
      bonus_bandwidth_kb: 123155
    )

    @beta_plan = BillingPlan.create(
      name: 'Early Adopters',
      stripe_plan_id: 'early-adopters',
      monthly_cents: 0, # $0.00/mo
      available: true,

      # Content creation and other permissions:
      universe_limit: 5,
      allows_core_content: true,
      allows_extended_content: false,
      allows_collective_content: false,
      allows_collaboration: false,
      bonus_bandwidth_kb: 123155
    )

    @premium_plan = BillingPlan.create(
      name: 'Premium',
      stripe_plan_id: 'premium',
      monthly_cents: 900,
      available: true,
      universe_limit: 5,
      allows_core_content: true,
      allows_extended_content: true,
      allows_collective_content: true,
      allows_collaboration: true,
      bonus_bandwidth_kb: 0
    )

    @premium_annual_plan = BillingPlan.create(
      name: 'Premium (annual)',
      stripe_plan_id: 'premium-annual',
      monthly_cents: 700,
      available: true,
      universe_limit: 5,
      allows_core_content: true,
      allows_extended_content: true,
      allows_collective_content: true,
      allows_collaboration: true,
      bonus_bandwidth_kb: 123155
    )
  end

  describe "User with no plan (fallback to Starter) tries to upgrade" do
    it "redirects to payment method form if they don't have a payment method saved" do
      expect(@user.active_subscriptions).to eq([])
      post :change, params: { stripe_plan_id: 'premium' }
      expect(subject).to redirect_to action: :information, plan: 'premium'
    end
  end

  describe "User on Starter" do
    before do
      # Create a Starter subscription for the user
      @user.update(selected_billing_plan_id: @free_plan.id)
    end

    it "redirects to payment method form if they don't have a payment method saved" do
      post :change, params: { stripe_plan_id: 'premium' }
      expect(subject).to redirect_to action: :information, plan: 'premium'
    end

    it "allows upgrading to Premium when they have a payment method saved" do
      # Re-stub Stripe::Customer.retrieve to include a payment method (source)
      stub_request(:get, "https://api.stripe.com/v1/customers/stripe-id")
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
              data: [Stripe::StripeObject.new]
            }
          }.to_json,
          headers: {}
        )

      expect(@user.selected_billing_plan_id).to eq(@free_plan.id)
      expect(@user.active_billing_plans).not_to eq([@premium_plan])

      post :change, params: { stripe_plan_id: 'premium' }

      @user.reload
      expect(@user.selected_billing_plan_id).to eq(@premium_plan.id)
      expect(@user.active_billing_plans).to eq([@premium_plan])
    end

    describe "Starter Permissions" do
      before do
        @user.update(selected_billing_plan_id: @free_plan.id)
      end

      it "allows Starter users to create core content types" do
        expect(@user.can_create?(Character)).to eq(true)
        expect(@user.can_create?(Location)).to eq(true)
        expect(@user.can_create?(Item)).to eq(true)
      end

      it "doesn't allow Starter users to create extended content types" do
        expect(@user.can_create?(Creature)).to eq(false)
        expect(@user.can_create?(Race)).to eq(false)
        expect(@user.can_create?(Religion)).to eq(false)
        expect(@user.can_create?(Group)).to eq(false)
        expect(@user.can_create?(Magic)).to eq(false)
        expect(@user.can_create?(Language)).to eq(false)
        expect(@user.can_create?(Flora)).to eq(false)
      end

      it "doesn't allow Starter users to create collective content types" do
        expect(@user.can_create?(Scene)).to eq(false)
      end
    end
  end

  describe "User on Premium" do
    before do
      # Create a premium subscription for the user
      @user.update(selected_billing_plan_id: @premium_plan.id)
    end

    it "allows downgrading to Starter" do
      # Downgrade to Starter
      post :change, params: { stripe_plan_id: 'starter' }

      @user.reload
      expect(@user.selected_billing_plan_id).to eq(@free_plan.id)
      expect(@user.active_billing_plans).to eq([@free_plan])
      expect(@user.active_subscriptions.map(&:billing_plan_id)).to eq([@free_plan.id])
    end

    describe "Premium Permissions" do
      it "allows Premium users to create core content types" do
        @user.update(selected_billing_plan_id: 4)
        expect(@user.can_create?(Character)).to eq(true)
        expect(@user.can_create?(Location)).to eq(true)
        expect(@user.can_create?(Item)).to eq(true)
      end

      it "allows Premium users to create extended content types" do
        @user.update(selected_billing_plan_id: 4)
        expect(@user.can_create?(Creature)).to eq(true)
        expect(@user.can_create?(Race)).to eq(true)
        expect(@user.can_create?(Religion)).to eq(true)
        expect(@user.can_create?(Group)).to eq(true)
        expect(@user.can_create?(Magic)).to eq(true)
        expect(@user.can_create?(Language)).to eq(true)
        expect(@user.can_create?(Flora)).to eq(true)
      end

      it "allows Premium users to create collective content types" do
        @user.update(selected_billing_plan_id: 4)
        expect(@user.can_create?(Scene)).to eq(true)
      end
    end
  end

  describe "Upload storage adjustments" do
    before do
      @user.active_subscriptions.create(billing_plan: @free_plan, start_date: Time.now - 5.days, end_date: Time.now + 5.days)
      @user.update(selected_billing_plan_id: @free_plan.id)
    end

    it 'grants storage space to a user after upgrading' do
      @user.update(upload_bandwidth_kb: 100)
      post :change, params: { stripe_plan_id: 'premium' }
      expect(@user.upload_bandwidth_kb).to eq(100 + @premium_plan.bonus_bandwidth_kb)
    end

    it 'decreases storage space for a user after downgrading' do
      @user.update(upload_bandwidth_kb: 100)
      post :change, params: { stripe_plan_id: 'starter' }
      expect(@user.upload_bandwidth_kb).to eq(100 - @premium_plan.bonus_bandwidth_kb)
    end

    it 'does not adjust storage space when going premium --> premium' do
      @user.update(upload_bandwidth_kb: 101)
      @user.update(selected_billing_plan_id: @premium_plan.id)
      post :change, params: { stripe_plan_id: @premium_annual_plan.stripe_plan_id }
      expect(@user.upload_bandwidth_kb).to eq(101)
    end

    it 'does not adjust storage space if no plan change is made' do
      @user.update(upload_bandwidth_kb: 101)
      @user.update(selected_billing_plan_id: @premium_annual_plan.stripe_plan_id)
      post :change, params: { stripe_plan_id: @premium_plan.stripe_plan_id }
      expect(@user.upload_bandwidth_kb).to eq(101)
    end
  end
end
