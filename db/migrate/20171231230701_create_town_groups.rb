class CreateTownGroups < ActiveRecord::Migration
  def change
    create_table :town_groups do |t|
      t.references :user, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
