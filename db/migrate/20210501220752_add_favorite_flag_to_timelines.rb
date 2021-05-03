class AddFavoriteFlagToTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :timelines, :favorite, :boolean
  end
end
