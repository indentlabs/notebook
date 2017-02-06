class RemovePasswordDigestFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password_digest, :string
  end
end
