class AddUserIdToCreatures < ActiveRecord::Migration
  def change
    add_column :creatures, :user_id, :integer
  end
end
