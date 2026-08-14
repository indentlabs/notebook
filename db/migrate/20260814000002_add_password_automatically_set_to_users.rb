class AddPasswordAutomaticallySetToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :password_automatically_set, :boolean, default: false
  end
end
