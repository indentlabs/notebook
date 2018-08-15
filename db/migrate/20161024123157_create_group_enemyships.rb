class CreateGroupEnemyships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_enemyships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :enemy_id
    end
  end
end
