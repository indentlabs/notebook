class RemovePasswordDigestFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :password_digest, :string
  end
end
