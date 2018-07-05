class CreateLingualism < ActiveRecord::Migration[4.2]
  def change
    create_table :lingualisms do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :spoken_language_id
    end
  end
end
