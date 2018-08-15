class CreatePlanets < ActiveRecord::Migration[4.2]
  def change
    create_table :planets do |t|
      t.string :name
      t.string :description
      t.string :size
      t.string :surface
      t.string :landmarks
      t.string :climate
      t.string :weather
      t.string :water_content
      t.string :natural_resources
      t.string :length_of_day
      t.string :length_of_night
      t.string :calendar_system
      t.string :population
      t.string :moons
      t.string :orbit
      t.string :visible_constellations
      t.string :first_inhabitants_story
      t.string :world_history
      t.string :public_notes
      t.string :private_notes
      t.string :privacy
      t.references :universe, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
