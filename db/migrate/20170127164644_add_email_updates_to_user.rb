class AddEmailUpdatesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_updates, :boolean, default: true
  end
end
