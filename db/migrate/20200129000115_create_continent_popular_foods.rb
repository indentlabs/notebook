class CreateContinentPopularFoods < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_popular_foods do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :popular_food, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
