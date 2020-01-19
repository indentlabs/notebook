class CreatePaypalInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :paypal_invoices do |t|
      t.string :paypal_id
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.integer :months
      t.integer :amount_cents

      t.timestamps
    end
  end
end
