class AddUserToContinentLandmarks < ActiveRecord::Migration[6.0]
  def change
    add_reference :continent_landmarks, :user, foreign_key: true
  end
end
