class CreateGroupLocationship < ActiveRecord::Migration[4.2]
  def change
    create_table :group_locationships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :location_id
    end
  end
end
