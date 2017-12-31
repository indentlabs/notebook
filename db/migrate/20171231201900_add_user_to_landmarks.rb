class AddUserToLandmarks < ActiveRecord::Migration
  def change
    add_reference :landmarks, :user, index: true, foreign_key: true
  end
end
