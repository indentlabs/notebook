class AddUserToTowns < ActiveRecord::Migration[4.2]
  def change
    add_reference :towns, :user, index: true, foreign_key: true
  end
end
