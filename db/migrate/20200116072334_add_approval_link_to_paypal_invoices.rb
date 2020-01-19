class AddApprovalLinkToPaypalInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :paypal_invoices, :approval_url, :string
  end
end
