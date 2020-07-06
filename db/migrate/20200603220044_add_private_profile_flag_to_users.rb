class AddPrivateProfileFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :private_profile, :boolean
    change_column_default(:users, :private_profile, false)

    User.where(private_profile: nil).update_all(private_profile: false)
  end
end
