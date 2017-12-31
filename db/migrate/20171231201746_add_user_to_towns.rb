class AddUserToTowns < ActiveRecord::Migration
  def change
    add_reference :towns, :user, index: true, foreign_key: true
  end
end
