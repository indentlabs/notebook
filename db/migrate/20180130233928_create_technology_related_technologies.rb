class CreateTechnologyRelatedTechnologies < ActiveRecord::Migration[4.2]
  def change
    create_table :technology_related_technologies do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.integer :related_technology_id

      t.timestamps null: false
    end
  end
end
