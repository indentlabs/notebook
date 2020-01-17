class AddPayerIdToPaypalInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :paypal_invoices, :payer_id, :string
  end
end
