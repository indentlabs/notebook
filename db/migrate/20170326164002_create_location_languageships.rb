class CreateLocationLanguageships < ActiveRecord::Migration[4.2]
  def change
    create_table :location_languageships do |t|
      t.integer :user_id
      t.integer :location_id
      t.integer :language_id

      t.timestamps null: false
    end
  end
end
