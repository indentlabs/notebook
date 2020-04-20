class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user
      t.string :message_html
      t.string :icon, default: 'notifications_active'
      t.datetime :happened_at
      t.datetime :viewed_at

      t.timestamps
    end
  end
end
