class StripeInvoiceEvents
  attr_reader :event
  attr_reader :user

  def initialize(event)
    @event = event
    @user = User.find_by(stripe_customer_id: stripe_customer)
  end

  def payment_succeeded
    return unless user.present?
    InvoicesMailer.dispatch_invoice(user.id)
  end


  def payment_failed
    return unless user.present?
    InvoicesMailer.problem_with_payment(user.id)
    if stripe_invoice.next_payment_attempt.blank?
      user.update(selected_billing_plan_id: 1)
      InvoicesMailer.downgraded_to_starter(user.id)
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
