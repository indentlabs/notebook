class CreateContinentCreatures < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_creatures do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :creature, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
