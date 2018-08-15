class AddBandwidthToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :upload_bandwidth_kb, :integer, default: 50_000 # 50 MB
  end
end
