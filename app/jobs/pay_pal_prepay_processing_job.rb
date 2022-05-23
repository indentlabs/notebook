class PayPalPrepayProcessingJob < ApplicationJob
  queue_as :paypal

  def perform(*args)
    invoice_id = args.shift
    invoice = PaypalInvoice.find_by(paypal_id: invoice_id)

    info = PaypalService.order_info(invoice_id)
    if info[:status] == 'CREATED'
      # If we're still in a CREATED state, requeue once after 8 hours, just in case
      # Paypal's webhook didn't hit our servers.
      if DateTime.current < invoice.created_at + 12.hours
        PayPalPrepayProcessingJob
          .set(wait: 8.hours)
          .perform_later(invoice.paypal_id)
      end

    elsif info[:status] == 'APPROVED'
      # Once a user has approved a payment, we need to capture that payment
      unless invoice.status == 'APPROVED'
        invoice.update(status: 'APPROVED')
        invoice.capture_funds!
      end

    elsif info[:status] == 'COMPLETED'
      # Once a payment has been captured, generate the code for use!
      unless invoice.status == 'COMPLETED'
        invoice.update(status: 'COMPLETED')
        invoice.generate_promo_code!

        # Add the extra Premium space
        SubscriptionService.add_any_referral_bonuses(invoice.user, 'premium')
        PremiumDowngradeJob.set(wait: (invoice.months).months).perform_later(invoice.user_id)
      end

    else
      # Something unexpected happened! Wow!
      invoice.update(status: info[:status])
      raise info.inspect
    
    end

  end
end
