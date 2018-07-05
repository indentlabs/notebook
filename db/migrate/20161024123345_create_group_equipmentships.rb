class CreateGroupEquipmentships < ActiveRecord::Migration[4.2]
  def change
    create_table :group_equipmentships do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :equipment_id
    end
  end
end
