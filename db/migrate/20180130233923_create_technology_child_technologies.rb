class CreateTechnologyChildTechnologies < ActiveRecord::Migration
  def change
    create_table :technology_child_technologies do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.integer :child_technology_id

      t.timestamps null: false
    end
  end
end
