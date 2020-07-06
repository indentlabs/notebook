class AddDescriptionToTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :timelines, :description, :string
  end
end
