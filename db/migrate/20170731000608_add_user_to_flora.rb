class AddUserToFlora < ActiveRecord::Migration[4.2]
  def change
    add_reference :floras, :user, index: true, foreign_key: true
  end
end
