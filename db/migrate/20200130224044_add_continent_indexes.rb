class AddContinentIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index(:continents, [:deleted_at, :id])
    add_index(:continents, [:deleted_at, :id, :universe_id])
    add_index(:continents, [:deleted_at, :id, :user_id])
    add_index(:continents, [:deleted_at, :user_id])
  end
end
