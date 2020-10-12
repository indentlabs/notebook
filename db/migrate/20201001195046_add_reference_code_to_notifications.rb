class AddReferenceCodeToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :reference_code, :string
  end
end
