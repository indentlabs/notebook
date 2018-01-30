class CreateTechnologyPlanets < ActiveRecord::Migration
  def change
    create_table :technology_planets do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.references :planet, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
