class AddMay24Indices < ActiveRecord::Migration[6.0]
  def change
    add_index :timelines, [:deleted_at, :user_id]
    add_index :documents, [:deleted_at, :universe_id]
    add_index :documents, [:deleted_at, :universe_id, :user_id]
    add_index :users, [:deleted_at, :id]
  end
end
