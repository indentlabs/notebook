class CreateDeityRelatedTowns < ActiveRecord::Migration[4.2]
  def change
    create_table :deity_related_towns do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deity, index: true, foreign_key: true
      t.integer :related_town_id

      t.timestamps null: false
    end
  end
end
