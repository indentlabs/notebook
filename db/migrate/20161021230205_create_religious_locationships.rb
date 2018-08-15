class CreateReligiousLocationships < ActiveRecord::Migration[4.2]
  def change
    create_table :religious_locationships do |t|
      t.integer :religion_id
      t.integer :practicing_location_id
      t.integer :user_id
    end
  end
end
