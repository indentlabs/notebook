class AddPasswordDigestToUsers < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :password, :old_password
    change_column_null :users, :old_password, true
    add_column :users, :password_digest, :string
  end
end
