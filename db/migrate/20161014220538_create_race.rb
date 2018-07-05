class CreateRace < ActiveRecord::Migration[4.2]
  def change
    create_table :races do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.integer :universe_id
      t.integer :user_id
      t.string :body_shape
      t.string :skin_colors
      t.string :height
      t.string :weight
      t.string :notable_features
      t.string :variance
      t.string :clothing
      t.string :strengths
      t.string :weaknesses
      t.string :traditions
      t.string :beliefs
      t.string :governments
      t.string :technologies
      t.string :occupations
      t.string :economics
      t.string :favorite_foods
      t.string :notable_events
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
