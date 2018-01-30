class RemoveLandmarksFromPlanets < ActiveRecord::Migration
  def change
    remove_column :planets, :landmarks
  end
end
