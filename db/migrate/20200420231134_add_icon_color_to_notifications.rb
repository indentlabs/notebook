class AddIconColorToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :icon_color, :string, default: 'blue'
  end
end
