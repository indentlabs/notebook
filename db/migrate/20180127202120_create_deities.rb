class CreateDeities < ActiveRecord::Migration
  def change
    create_table :deities do |t|
      t.string :name
      t.string :description
      t.string :other_names
      t.string :physical_description
      t.string :height
      t.string :weight
      t.string :symbols
      t.string :elements
      t.string :strengths
      t.string :weaknesses
      t.string :prayers
      t.string :rituals
      t.string :human_interaction
      t.string :notable_events
      t.string :family_history
      t.string :life_story
      t.string :notes
      t.string :private_notes
      t.string :privacy
      t.references :user, index: true, foreign_key: true
      t.references :universe, index: true, foreign_key: true
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
