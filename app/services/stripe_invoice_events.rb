class StripeInvoiceEvents
  attr_reader :event
  attr_reader :user

  def initialize(event)
    @event = event
    @user = User.find_by(stripe_customer_id: stripe_customer)
  end

  def payment_succeeded
    return unless user.present?
    # Stripe sends receipts currently, so we don't need to.
    #InvoicesMailer.dispatch_invoice(user.id).deliver_now!
  end


  def payment_failed
    return unless user.present?
    # todo style email
    #InvoicesMailer.problem_with_payment(user.id).deliver_now!
    if stripe_invoice.next_payment_attempt.blank?
      user.update(selected_billing_plan_id: 1)
      # todo style email
      #InvoicesMailer.downgraded_to_starter(user.id).deliver_now!
    end
  end

  private

  def stripe_customer
    stripe_invoice.customer
  end

  def stripe_invoice
    event.data.object
  end
end
