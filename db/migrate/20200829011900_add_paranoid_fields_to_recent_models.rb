class AddParanoidFieldsToRecentModels < ActiveRecord::Migration[6.0]
  def change
    add_column :page_collections, :deleted_at, :datetime
    add_column :page_collection_submissions, :deleted_at, :datetime
    add_column :paypal_invoices, :deleted_at, :datetime
    add_column :timeline_events, :deleted_at, :datetime
  end
end
