class CreateGroupClientships < ActiveRecord::Migration
  def change
    create_table :group_clientships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :client_id
    end
  end
end
