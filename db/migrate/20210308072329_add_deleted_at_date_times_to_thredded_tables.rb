class AddDeletedAtDateTimesToThreddedTables < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_topics, :deleted_at, :datetime
    add_index :thredded_topics, :deleted_at
    add_index :thredded_topics, [:deleted_at, :messageboard_id]
    add_index :thredded_topics, [:deleted_at, :user_id]

    add_column :thredded_posts, :deleted_at, :datetime
    add_index :thredded_posts, :deleted_at
    add_index :thredded_posts, [:deleted_at, :messageboard_id]
    add_index :thredded_posts, [:deleted_at, :postable_id]
    add_index :thredded_posts, [:deleted_at, :user_id]
  end
end
