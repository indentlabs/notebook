class CreateTechnologyParentTechnologies < ActiveRecord::Migration[4.2]
  def change
    create_table :technology_parent_technologies do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.integer :parent_technology_id

      t.timestamps null: false
    end
  end
end
