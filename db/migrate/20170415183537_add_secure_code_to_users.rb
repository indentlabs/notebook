class AddSecureCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :secure_code, :string
  end
end
