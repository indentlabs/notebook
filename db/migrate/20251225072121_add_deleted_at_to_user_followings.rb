class AddDeletedAtToUserFollowings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_followings, :deleted_at, :datetime
    add_index :user_followings, :deleted_at
  end
end
