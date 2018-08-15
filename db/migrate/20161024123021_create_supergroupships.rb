class CreateSupergroupships < ActiveRecord::Migration[4.2]
  def change
    create_table :supergroupships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :supergroup_id
    end
  end
end
