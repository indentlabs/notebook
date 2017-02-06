class CreateCreatures < ActiveRecord::Migration
  def change
    create_table :creatures do |t|
      t.string :name
      t.string :description
      t.string :type_of
      t.string :other_names
      t.integer :universe_id
      t.string :color
      t.string :shape
      t.string :size
      t.string :notable_features
      t.string :materials
      t.string :preferred_habitat
      t.string :sounds
      t.string :strengths
      t.string :weaknesses
      t.string :spoils
      t.string :aggressiveness
      t.string :attack_method
      t.string :defense_method
      t.string :maximum_speed
      t.string :food_sources
      t.string :migratory_patterns
      t.string :reproduction
      t.string :herd_patterns
      t.string :similar_animals
      t.string :symbolisms

      t.timestamps null: false
    end
  end
end
