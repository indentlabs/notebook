class RemoveLandmarksFromPlanets < ActiveRecord::Migration[4.2]
  def change
    remove_column :planets, :landmarks
  end
end
