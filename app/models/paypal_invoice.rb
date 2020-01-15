class PaypalInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :page_unlock_promo_code, optional: true

  after_create :watch_for_approval

  def next_step_url
    # switch to receipt after approving
    self.approval_url
  end

  def watch_for_approval
    PaypalAcceptanceWaitJob.perform_later(self.paypal_id)
  end

  def capture_funds!
    PaypalService.capture_invoice_funds(self.paypal_id)
  end

  def generate_promo_code!
    self.page_unlock_promo_code = PageUnlockPromoCode.create(
      code: 'PP' + (0...12).map { (65 + rand(26)).chr }.join,
      page_types: Rails.application.config.content_types[:premium].map(&:name),
      uses_remaining: 1,
      days_active: 30 * self.months.to_i,
      internal_description: "Prepaid with PayPal",
      description: "Prepaid Premium subscription"
    )
    self.save!
  end

  def activateable?
    self.status == 'COMPLETED' &&
      page_unlock_promo_code.present? &&
      page_unlock_promo_code.uses_remaining > 0
  end
end
