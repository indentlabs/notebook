class AddTimeZoneToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :time_zone, :string, default: 'UTC', null: false
  end
end
