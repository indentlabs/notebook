class AddFieldsToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :laws, :string
    add_column :locations, :climate, :string
    add_column :locations, :founding_story, :string
    add_column :locations, :sports, :string
  end
end
