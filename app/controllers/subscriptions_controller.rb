class SubscriptionsController < ApplicationController
  protect_from_forgery except: :stripe_webhook

  before_action :authenticate_user!, except: [:redeem, :faq]

  before_action :set_navbar_actions,    except: [:redeem, :prepay_paid]
  before_action :set_sidenav_expansion, except: [:redeem, :prepay_paid]

  # General billing page
  def new
    @sidenav_expansion = 'my account'

    # We only support a single billing plan right now, so just grab the first one. If they don't have an active plan,
    # we also treat them as if they have a Starter plan.
    @active_billing_plan = current_user.active_billing_plans.first || BillingPlan.find_by(stripe_plan_id: 'starter')
    @active_promotions   = current_user.active_promotions
    @active_promo_code   = @active_promotions.first.try(:page_unlock_promo_code)

    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  end

  def history
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    @stripe_payment_methods = @stripe_customer.list_payment_methods(type: 'card')
    @stripe_invoices = Stripe::Invoice.list({
      customer: current_user.stripe_customer_id
    })
  end

  def show
  end

  def prepay
    @invoices = current_user.paypal_invoices
      .where(status: 'COMPLETED')
      .includes(:page_unlock_promo_code)
      .order('id desc')
      .sort_by { |invoice| invoice.page_unlock_promo_code.uses_remaining }
      .reverse

    promo_code_ids = @invoices.map(&:page_unlock_promo_code_id).flatten
    @promo_codes = PageUnlockPromoCode.where(id: promo_code_ids)
  end

  def prepay_paid
    @invoice = current_user.paypal_invoices.find_by(paypal_id: params[:token])
    raise "Error: no invoice found" unless @invoice.present?

    # Track Paypal's PayerID returned in case we need it in the future
    @invoice.update(payer_id: params[:PayerID])
    
    # Kick the process job off inline so it'll be done capturing the funds by the time we redirect
    PayPalPrepayProcessingJob.perform_now(@invoice.paypal_id)

    redirect_to :prepay
  end

  def redeem
    @code = PageUnlockPromoCode.find_by(code: params[:code])
  end

  def prepay_redirect_to_paypal
    months  = params[:months].to_i

    # Create an invoice on Paypal to be paid
    ppi     = PaypalService.create_prepay_invoice(months)

    # Create a mirrored invoice of our own to mark paid later
    invoice = PaypalInvoice.create!(
      user:         current_user,
      paypal_id:    ppi.id,
      status:       ppi.status,
      months:       months,
      amount_cents: 100 * PaypalService.months_price(months),
      approval_url: ppi.links.detect { |l| l.rel == "approve" }.href
    )

    # Send the user off to pay!
    # redirect_to PaypalService.checkout_url(invoice, prepay_path)
    redirect_to invoice.approval_url
  end

  # Delete after a successful release
  # def capture_paypal_prepay
  #   request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new("APPROVED-ORDER-ID")

  #   begin
  #       # Call API with your client and get a response for your call
  #       response = client.execute(request) 
        
  #       # If call returns body in response, you can get the deserialized version from the result attribute of the response
  #       order = response.result
  #       puts order
  #   rescue PayPalHttp::HttpError => ioe
  #       # Something went wrong server-side
  #       puts ioe.status_code
  #       puts ioe.headers["debug_id"]
  #   end
  # end

  def change
    new_plan_id = params[:stripe_plan_id]
    possible_plan_ids = SubscriptionService.available_plans.pluck(:stripe_plan_id)

    unless possible_plan_ids.include?(new_plan_id)
      raise "Invalid billing plan ID: #{new_plan_id}"
    end

    result = move_user_to_plan_requested(new_plan_id)

    if result == :payment_method_needed
      redirect_to payment_info_path(plan: new_plan_id)
    elsif result == :failed_card
      flash[:alert] = "We couldn't upgrade you to Premium because your card was denied. Please double check that your information is correct."
      return redirect_to payment_info_path(plan: new_plan_id)
    else
      redirect_to(subscription_path, notice: "Your plan was successfully changed.")
    end
  end

  # This isn't actually needed since we change the paid plan to the free plan, but will be needed when we
  # add a way to deactivate/delete accounts, so the logic is here for when it's needed.
  # def cancel
  #   # Fetch the user's current subscription
  #   stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
  #   stripe_subscription = stripe_customer.subscriptions.data[0]

  #   # Cancel it at the end of its effective period on Stripe's end, so they don't get rebilled
  #   stripe_subscription.delete(at_period_end: true)
  # end

  # Billing information page
  def information
    @selected_plan = BillingPlan.find_by(stripe_plan_id: params['plan'], available: true)
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  end

  # Save a payment method
  def information_change
    valid_token = params[:stripeToken]
    if valid_token.nil?
      flash[:alert] = "We couldn't validate the card information you entered. Please make sure you have Javascript enabled in your browser."
      return redirect_back fallback_location: payment_info_path
    end

    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]
    begin
      # Delete all existing payment methods to have our new one "replace" them
      existing_payment_methods = stripe_customer.list_payment_methods(type: 'card')
      existing_payment_methods.data.each do |payment_method|
        payment_method.detach
      end

      # Add the new card info
      payment_method = Stripe::PaymentMethod.create({
        type: 'card',
        card: { token: valid_token }
      })
      payment_method.attach(customer: stripe_customer.id)
    rescue Stripe::CardError => e
      flash[:alert] = "We couldn't save your payment information because #{e.message.downcase} Please double check that your information is correct."
      return redirect_back fallback_location: payment_info_path
    end

    new_plan_id = params[:plan]
    result = move_user_to_plan_requested(new_plan_id) if new_plan_id

    if result == :payment_method_needed
      redirect_to payment_info_path(plan: new_plan_id)
    elsif result == :failed_card
      return
    else
      redirect_to(subscription_path, notice: 'Your plan was successfully changed.')
    end

  end

  def delete_payment_method
    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]

    payment_methods = stripe_customer.list_payment_methods(type: 'card')
    payment_methods.data.each do |payment_method|
      payment_method.detach
    end

    notice = ['Your payment method has been successfully deleted.']

    # Check if user has a non-starter subscription using modern API
    current_price_id = stripe_subscription.items.data[0].price.id
    if current_price_id != 'starter'
      # Cancel the user's at the end of its effective period on Stripe's end, so they don't get rebilled
      stripe_subscription.delete(at_period_end: true)

      active_billing_plan = BillingPlan.find_by(stripe_plan_id: current_price_id)
      if active_billing_plan
        notice << "Your #{active_billing_plan.name} subscription will end on #{Time.at(stripe_subscription.current_period_end).strftime('%B %d')}."
      end
    end

    flash[:notice] = notice.join ' '
    redirect_back fallback_location: subscription_path
  end

  def stripe_webhook
    #todo handle webhooks :(
  end

  def redeem_code
    code = PageUnlockPromoCode.find_by(code: params.require(:promotional_code).permit(:promo_code)[:promo_code])

    if code.nil?
      redirect_back(fallback_location: subscription_path, alert: "This isn't a valid promo code.")
      return
    end

    if code.uses_remaining < 1
      redirect_back(fallback_location: subscription_path, alert: "This promo code has expired!")
      return
    end

    if code.users.include?(current_user)
      redirect_back(fallback_location: subscription_path, alert: "You've already activated this promo code!")
      return
    end      

    # If it looks like a valid code and quacks like a valid code, it's probably a valid code
    code.activate!(current_user)

    # Also, give the user the Premium upload bandwidth
    # TODO we should probably use SubscriptionService#recalculate_bandwidth_for() here so we can reduce
    #      code reuse
    premium_bandwidth = 10_000_000 # skipping a lookup to BillingPlan.find(4).bonus_bandwidth_kb
    bandwidth_remaining = premium_bandwidth - current_user.image_uploads.sum(:src_file_size) / 1000

    # Also add referral bandwidth bonus to total (100MB per referral)
    bandwidth_remaining += current_user.referrals.count * 100_000

    current_user.update(upload_bandwidth_kb: bandwidth_remaining)

    current_user.notifications.create(
      message_html:     "<div class='yellow-text text-darken-4'>You activated a Premium Code!</div><div>Click here to turn on your Premium pages.</div>",
      icon:             'star',
      icon_color:       'text-darken-3 yellow',
      happened_at:      DateTime.current,
      passthrough_link: Rails.application.routes.url_helpers.customization_content_types_path,
      reference_code:   'premium-activation'
    )

    redirect_back(fallback_location: subscription_path, notice: "Promo code successfully activated!")
  end

  def faq
  end

  private

  def move_user_to_plan_requested(plan_id)
    if plan_id == 'starter'
      process_plan_change(current_user, plan_id)
    else
      stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id

      # If we're upgrading to premium, we want to check that a payment method
      # is already on file. If it is, we process the plan change. If it's not,
      # we redirect to the payment method page.
      payment_methods = stripe_customer.list_payment_methods(type: 'card')
      if payment_methods.data.length > 0
        process_plan_change(current_user, plan_id)
      else
        return :payment_method_needed
      end
    end
  end

  def process_plan_change(user, new_plan_id)
    # General flow we're going to take here:
    # 1. Cancel all existing plans, reversing their benefits
    SubscriptionService.cancel_all_existing_subscriptions(user)

    # 2. Add a new plan, adding its benefits
    SubscriptionService.add_subscription(user, new_plan_id)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end

  def set_navbar_actions
    if user_signed_in? 
      @navbar_actions = [{
        label: "Your plan",
        href: main_app.subscription_path
      }, {
        label: "Billing history",
        href: main_app.billing_history_path
      },
      {
        label: 'Billing FAQ',
        href: main_app.billing_faq_path
      }]
    end
  end
end
