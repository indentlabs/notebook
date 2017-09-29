class AddFluidPreferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :fluid_preference, :boolean
  end
end
