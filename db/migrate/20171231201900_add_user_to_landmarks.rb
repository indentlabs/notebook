class AddUserToLandmarks < ActiveRecord::Migration[4.2]
  def change
    add_reference :landmarks, :user, index: true, foreign_key: true
  end
end
