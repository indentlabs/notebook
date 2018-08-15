class CreateRaceships < ActiveRecord::Migration[4.2]
  def change
    create_table :raceships do |t|
      t.integer :user_id
      t.integer :character_id
      t.integer :race_id
    end
  end
end
