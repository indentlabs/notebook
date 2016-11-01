class CreateHeadquarterships < ActiveRecord::Migration
  def change
    create_table :headquarterships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :headquarter_id
    end
  end
end
