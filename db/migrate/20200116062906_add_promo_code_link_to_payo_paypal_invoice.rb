class AddPromoCodeLinkToPayoPaypalInvoice < ActiveRecord::Migration[6.0]
  def change
    add_reference :paypal_invoices, :page_unlock_promo_code, foreign_key: true
  end
end
