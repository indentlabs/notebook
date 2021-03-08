class AddIndexToDocumentsOnUsersAndDeletedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :documents, [:user_id, :deleted_at]
  end
end
