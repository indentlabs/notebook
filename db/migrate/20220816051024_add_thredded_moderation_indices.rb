class AddThreddedModerationIndices < ActiveRecord::Migration[6.1]
  def change
    add_index :thredded_posts, :created_at
    add_index :thredded_posts, [:created_at, :postable_id]
  end
end
