class RemoveGlobalUsersEmailIndex < ActiveRecord::Migration[5.2]
  def change
    # Since we default_scope to deleted_at:nil for all User lookups, we index [email, deleted_at] now
    # and this index is no longer needed.
    remove_index :users, name: "index_users_on_email"
  end
end
