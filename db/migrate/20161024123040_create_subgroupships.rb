class CreateSubgroupships < ActiveRecord::Migration
  def change
    create_table :subgroupships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :subgroup_id
    end
  end
end
