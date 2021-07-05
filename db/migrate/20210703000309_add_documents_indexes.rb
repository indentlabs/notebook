class AddDocumentsIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :documents, [:deleted_at, :universe_id]
    add_index :documents, [:deleted_at, :universe_id, :user_id]

    add_index :folders, [:user_id, :context]
    add_index :folders, [:user_id, :context, :parent_folder_id]
  end
end
