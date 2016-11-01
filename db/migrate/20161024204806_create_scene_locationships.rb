class CreateSceneLocationships < ActiveRecord::Migration
  def change
    create_table :scene_locationships do |t|
      t.integer :user_id
      t.integer :scene_id
      t.integer :scene_location_id
    end
  end
end
