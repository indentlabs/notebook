class AddClickthroughLinkToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :passthrough_link, :string
  end
end
