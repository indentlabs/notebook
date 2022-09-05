class AddDeletedAtAndIdIndexToThredded < ActiveRecord::Migration[6.1]
  def change
    add_index :thredded_posts, [:id, :deleted_at]
  end
end
