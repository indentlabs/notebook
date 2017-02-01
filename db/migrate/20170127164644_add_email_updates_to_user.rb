class AddEmailUpdatesToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_updates, :boolean, default: true
  end
end
