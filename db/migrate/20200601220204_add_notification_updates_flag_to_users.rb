class AddNotificationUpdatesFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification_updates, :boolean
    change_column_default(:users, :notification_updates, true)

    User.where(notification_updates: nil).update_all(notification_updates: true)
  end
end
