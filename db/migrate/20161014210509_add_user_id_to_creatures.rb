class AddUserIdToCreatures < ActiveRecord::Migration[4.2]
  def change
    add_column :creatures, :user_id, :integer
  end
end
