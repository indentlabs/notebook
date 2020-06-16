class AddFieldsToTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :timelines, :subtitle, :string
    add_column :timelines, :notes, :string
    add_column :timelines, :private_notes, :string
  end
end
