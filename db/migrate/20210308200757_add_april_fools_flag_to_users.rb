class AddAprilFoolsFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :enabled_april_fools, :boolean
  end
end
