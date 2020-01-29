class CreateContinentTraditions < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_traditions do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :tradition, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
