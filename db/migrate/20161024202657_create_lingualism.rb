class CreateLingualism < ActiveRecord::Migration
  def change
    create_table :lingualisms do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :spoken_language_id
    end
  end
end
