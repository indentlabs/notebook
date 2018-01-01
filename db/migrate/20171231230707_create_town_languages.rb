class CreateTownLanguages < ActiveRecord::Migration
  def change
    create_table :town_languages do |t|
      t.references :user, index: true, foreign_key: true
      t.references :town, index: true, foreign_key: true
      t.references :language, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
