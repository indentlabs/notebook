class CreateTechnologyCreatures < ActiveRecord::Migration
  def change
    create_table :technology_creatures do |t|
      t.references :user, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true
      t.references :creature, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
