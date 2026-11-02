require 'test_helper'

class StripeApiVersionTest < ActiveSupport::TestCase
  test "the pinned Stripe API version matches the one the stripe gem is built for" do
    assert_equal Stripe::ApiVersion::CURRENT, STRIPE_API_VERSION, <<~MSG
      The stripe gem now targets API version #{Stripe::ApiVersion::CURRENT}, but our
      billing code is pinned to #{STRIPE_API_VERSION} (config/initializers/stripe.rb).

      Before bumping the pin, read Stripe's changelog for every version in between
      (https://docs.stripe.com/changelog) and check what changed for the objects we
      use: Customer, Subscription, Invoice, PaymentMethod and Price. Then click
      through the billing pages on staging.
    MSG
  end

  test "Stripe requests use the pinned API version" do
    assert_equal STRIPE_API_VERSION, Stripe.api_version
  end
end
