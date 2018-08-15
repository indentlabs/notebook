class AddSecureCodeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :secure_code, :string
  end
end
